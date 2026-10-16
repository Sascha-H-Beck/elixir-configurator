defmodule Elixirmachine.Features.Catalog do
  @moduledoc false

  alias Elixirmachine.Config.{DepCatalog, SectionVisibility, Wizard.Sync}
  alias Elixirmachine.Features.Behaviour
  alias Elixirmachine.Generations.Generation

  @selectable_modules [
    Elixirmachine.Features.EctoPostgres,
    Elixirmachine.Features.EctoEts,
    Elixirmachine.Features.Finch,
    Elixirmachine.Features.DaisyUi,
    Elixirmachine.Features.PetalUi,
    Elixirmachine.Features.Ash,
    Elixirmachine.Features.Rabbitmq,
    Elixirmachine.Features.MsAdUeberauth,
    Elixirmachine.Features.MsAdElixirAuth,
    Elixirmachine.Features.Oban,
    Elixirmachine.Features.AshOban,
    Elixirmachine.Features.Elasticsearch,
    Elixirmachine.Features.Solr,
    Elixirmachine.Features.AshAi,
    Elixirmachine.Features.Langchain,
    Elixirmachine.Features.Sagents,
    Elixirmachine.Features.CodeQuality.Credo,
    Elixirmachine.Features.CodeQuality.Sobelow,
    Elixirmachine.Features.CodeQuality.Excoveralls,
    Elixirmachine.Features.CodeQuality.MixAudit,
    Elixirmachine.Features.Styler,
    Elixirmachine.Features.Dialyxir,
    Elixirmachine.Features.Tidewave,
    Elixirmachine.Features.Sourceror
  ]

  @scaffold_modules [
    Elixirmachine.Features.OtpScaffold,
    Elixirmachine.Features.Liveview,
    Elixirmachine.Features.PhoenixApi
  ]

  @internal_ids ~w(liveview phoenix_api otp_scaffold postgres)

  def all_modules, do: @selectable_modules ++ @scaffold_modules

  def selectable_modules, do: @selectable_modules

  def list, do: Enum.map(@selectable_modules, &serialize_package/1)

  def selectable, do: Enum.reject(list(), & &1.coming_soon)

  def locked_features(:phoenix_api), do: ["ecto_postgres"]
  def locked_features(:phoenix_liveview), do: ["ecto_postgres"]
  def locked_features(:standalone_otp), do: []
  def locked_features(_), do: []

  def packages_for_section(section, project_type, configuration) do
    configuration = SectionVisibility.normalize_configuration(configuration, project_type)
    locked = MapSet.new(locked_features(project_type))

    @selectable_modules
    |> Enum.filter(fn mod -> DepCatalog.section_for(mod.id()) == section end)
    |> Enum.map(&package_for(&1, project_type, configuration, locked))
  end

  def packages_for(project_type, configuration \\ %{}) do
    SectionVisibility.visible_sections(project_type, configuration)
    |> Enum.reject(&(&1 == :core))
    |> Enum.flat_map(&packages_for_section(&1, project_type, configuration))
  end

  def resolve_configuration(project_type, params)
      when project_type in [:standalone_otp, :phoenix_api, :phoenix_liveview] do
    params = params |> stringify_keys() |> Sync.sync_all()
    configuration = normalize_configuration_map(params)
    selected = features_from_params(params)
    derived = Sync.derived_feature_ids(project_type, configuration)
    locked = locked_features(project_type)

    resolve_selection(
      project_type,
      selected,
      acceptance_from_params(params),
      configuration,
      derived,
      locked
    )
  end

  def resolve_selection(
        project_type,
        selected,
        accepted_required \\ :skip_acceptance,
        configuration \\ %{},
        derived \\ nil,
        locked \\ nil
      )
      when project_type in [:standalone_otp, :phoenix_api, :phoenix_liveview] do
    selected = normalize_id_list(selected)
    locked = locked || locked_features(project_type)
    derived = derived || Sync.derived_feature_ids(project_type, configuration)
    configuration = SectionVisibility.normalize_configuration(configuration, project_type)

    with :ok <- validate_known(selected ++ locked),
         :ok <- validate_not_coming_soon(selected),
         :ok <- validate_availability(selected, project_type) do
      implicit = implicit_ids(project_type, configuration)
      effective = normalize_id_list(selected ++ derived ++ locked)
      expanded = expand_id_strings(effective)

      required_additions =
        ((((expanded -- selected) -- derived) -- locked) -- implicit)
        |> Enum.uniq()
        |> Enum.sort()

      resolved = expanded |> Enum.uniq() |> Enum.sort()

      accepted =
        case accepted_required do
          :skip_acceptance -> required_additions
          :auto -> required_additions
          list when is_list(list) -> normalize_id_list(list)
        end

      with :ok <- validate_conflicts(resolved),
           :ok <- validate_acceptance(required_additions, accepted, accepted_required) do
        {:ok,
         %{
           selected: selected,
           locked: locked,
           implicit: implicit,
           required_additions: required_additions,
           required_details: required_details(selected, required_additions),
           resolved: resolved,
           accepted_required: accepted,
           can_generate: acceptance_complete?(required_additions, accepted),
           configuration: configuration
         }}
      end
    end
  end

  def normalize_config(attrs) when is_map(attrs) do
    attrs = stringify_keys(attrs)

    with {:ok, project_type} <- parse_project_type(attrs["project_type"]),
         {:ok, target_os} <- parse_target_os(attrs["target_os"]) do
      accepted_mode = acceptance_mode(attrs)

      with {:ok, resolution} <- resolve_configuration(project_type, attrs),
           :ok <-
             validate_acceptance(
               resolution.required_additions,
               resolution.accepted_required,
               accepted_mode
             ) do
        {:ok,
         %{
           project_name: String.trim(attrs["project_name"] || ""),
           project_type: project_type,
           target_os: target_os,
           output_path: String.trim(attrs["output_path"] || ""),
           features: resolution.selected,
           configuration: resolution.configuration
         }}
      end
    else
      {:error, message} when is_binary(message) -> {:error, message}
      other -> other
    end
  end

  def enabled_modules(%Generation{} = generation) do
    configuration = generation.configuration || %{}
    feature_ids = effective_features(generation)

    scaffold_modules(generation.project_type, configuration) ++
      feature_modules(feature_ids)
  end

  def effective_features(%Generation{} = generation) do
    configuration = generation.configuration || %{}

    normalize_id_list(
      generation.features ++
        locked_features(generation.project_type) ++
        Sync.derived_feature_ids(generation.project_type, configuration)
    )
  end

  def adjust_selected_for_acceptance(selected, accepted, required_additions) do
    missing = required_additions -- accepted

    Enum.reduce(missing, selected, fn req_id, sel ->
      Enum.reject(sel, fn sel_id ->
        package_requires?(sel_id, req_id)
      end)
    end)
  end

  def module_for(id) when is_atom(id) do
    Enum.find(all_modules(), fn mod -> mod.id() == id end)
  end

  def module_for(id) when is_binary(id) do
    Enum.find(all_modules(), fn mod -> Atom.to_string(mod.id()) == id end)
  end

  def reset_features_for_project_type(_project_type, features, _configuration) do
    normalize_id_list(features)
  end

  defp scaffold_modules(:standalone_otp, _configuration) do
    [Elixirmachine.Features.OtpScaffold]
  end

  defp scaffold_modules(:phoenix_api, _configuration) do
    [Elixirmachine.Features.PhoenixApi]
  end

  defp scaffold_modules(:phoenix_liveview, _configuration) do
    [Elixirmachine.Features.Liveview]
  end

  defp feature_modules(feature_ids) do
    feature_ids
    |> Enum.map(&module_for/1)
    |> Enum.reject(fn
      nil -> true
      mod -> Behaviour.scaffold?(mod)
    end)
    |> Enum.uniq()
  end

  @wizard_managed DepCatalog.wizard_managed_ids()

  defp features_from_params(params) do
    params
    |> Map.get("features", [])
    |> List.wrap()
    |> normalize_id_list()
    |> Enum.reject(&(&1 in @wizard_managed))
  end

  defp normalize_configuration_map(params) do
    params
    |> Map.get("configuration", %{})
    |> case do
      config when is_map(config) ->
        project_type = Map.get(params, "project_type", "phoenix_liveview")

        config
        |> stringify_keys()
        |> then(fn cfg ->
          Map.merge(SectionVisibility.default_configuration(project_type), cfg)
        end)

      _ ->
        SectionVisibility.default_configuration(
          Map.get(params, "project_type", "phoenix_liveview")
        )
    end
  end

  defp acceptance_from_params(params) do
    if Map.has_key?(params, "accepted_required") do
      normalize_id_list(Map.get(params, "accepted_required", []))
    else
      :auto
    end
  end

  defp package_for(mod, project_type, configuration, locked) do
    package = serialize_package(mod, configuration)
    locked? = Atom.to_string(mod.id()) in locked

    cond do
      locked? ->
        Map.merge(package, %{
          selectable: false,
          locked: true,
          disabled_reason: "Included with project type"
        })

      not ash_available?(mod, configuration) ->
        Map.merge(package, %{
          selectable: false,
          locked: false,
          disabled_reason: "Requires PostgreSQL storage"
        })

      mod.coming_soon?() ->
        Map.merge(package, %{
          selectable: false,
          locked: false,
          disabled_reason: "Coming soon"
        })

      not available?(mod.available_for(), project_type) ->
        Map.merge(package, %{
          selectable: false,
          locked: false,
          disabled_reason: "Not available for this project type"
        })

      true ->
        Map.merge(package, %{selectable: true, locked: false, disabled_reason: nil})
    end
  end

  defp serialize_package(mod, _configuration \\ %{}) do
    %{
      id: Atom.to_string(mod.id()),
      label: mod.label(),
      description: mod.description(),
      section: DepCatalog.section_for(mod.id()),
      requires: Enum.map(mod.requires(), &Atom.to_string/1),
      conflicts_with: Enum.map(mod.conflicts_with(), &Atom.to_string/1),
      available_for: Atom.to_string(mod.available_for()),
      coming_soon: mod.coming_soon?(),
      mix_deps: mix_deps_for(mod.id())
    }
  end

  defp mix_deps_for(:ecto_postgres), do: ["ecto_sql", "postgrex"]
  defp mix_deps_for(:ecto_ets), do: ["ecto_ets"]
  defp mix_deps_for(:finch), do: ["finch"]
  defp mix_deps_for(:ash), do: ["ash", "ash_postgres", "ash_phoenix"]
  defp mix_deps_for(:credo), do: ["credo ~> 1.7"]
  defp mix_deps_for(:sobelow), do: ["sobelow ~> 0.12"]
  defp mix_deps_for(:excoveralls), do: ["excoveralls ~> 0.10"]
  defp mix_deps_for(:mix_audit), do: ["mix_audit ~> 2.1"]
  defp mix_deps_for(:petal_ui), do: ["petal_components ~> 2.9"]
  defp mix_deps_for(:rabbitmq), do: ["amqp ~> 4.1.0"]
  defp mix_deps_for(_), do: []

  defp feature_atom(id) when is_binary(id) do
    case module_for(id) do
      nil -> nil
      mod -> mod.id()
    end
  end

  defp implicit_ids(:standalone_otp, _), do: []
  defp implicit_ids(:phoenix_api, _), do: []
  defp implicit_ids(:phoenix_liveview, _), do: ["liveview"]

  defp expand_id_strings(ids) do
    ids
    |> Enum.map(&feature_atom/1)
    |> Enum.reject(&is_nil/1)
    |> expand_loop([])
    |> Enum.map(&Atom.to_string/1)
    |> Enum.uniq()
  end

  defp expand_loop([], acc), do: Enum.reverse(acc)

  defp expand_loop([id | rest], acc) do
    if id in acc do
      expand_loop(rest, acc)
    else
      requires =
        case module_for(id) do
          nil -> []
          mod -> mod.requires()
        end

      expand_loop(requires ++ rest, [id | acc])
    end
  end

  defp required_details(selected, required_additions) do
    Enum.map(required_additions, fn req_id ->
      parents =
        Enum.filter(selected, fn sel_id ->
          package_requires?(sel_id, req_id)
        end)

      %{
        id: req_id,
        label: package_label(req_id),
        required_by: parents
      }
    end)
  end

  defp package_requires?(package_id, required_id) do
    case module_for(package_id) do
      nil -> false
      mod -> required_id in Enum.map(mod.requires(), &Atom.to_string/1)
    end
  end

  defp package_label(id) do
    case module_for(id) do
      nil -> id
      mod -> mod.label()
    end
  end

  defp acceptance_mode(attrs) do
    if Map.has_key?(attrs, "accepted_required") do
      normalize_id_list(attrs["accepted_required"])
    else
      :auto
    end
  end

  defp validate_acceptance(_required, _accepted, :skip_acceptance), do: :ok
  defp validate_acceptance(_required, _accepted, :auto), do: :ok

  defp validate_acceptance(required, accepted, _mode) when is_list(accepted) do
    missing = required -- accepted

    if missing == [],
      do: :ok,
      else: {:error, "accept required packages: #{Enum.join(missing, ", ")}"}
  end

  defp acceptance_complete?(required, accepted), do: Enum.all?(required, &(&1 in accepted))

  defp validate_not_coming_soon(ids) do
    coming =
      Enum.filter(ids, fn id ->
        case module_for(id) do
          nil -> false
          mod -> mod.coming_soon?()
        end
      end)

    if coming == [],
      do: :ok,
      else: {:error, "packages not available yet: #{Enum.join(coming, ", ")}"}
  end

  defp normalize_id_list(list) when is_list(list) do
    list
    |> Enum.map(&to_string/1)
    |> Enum.reject(&(&1 in ["" | @internal_ids]))
    |> Enum.uniq()
  end

  defp normalize_id_list(_), do: []

  defp parse_project_type("standalone_otp"), do: {:ok, :standalone_otp}
  defp parse_project_type("phoenix_api"), do: {:ok, :phoenix_api}
  defp parse_project_type("phoenix_liveview"), do: {:ok, :phoenix_liveview}
  defp parse_project_type(:standalone_otp), do: {:ok, :standalone_otp}
  defp parse_project_type(:phoenix_api), do: {:ok, :phoenix_api}
  defp parse_project_type(:phoenix_liveview), do: {:ok, :phoenix_liveview}
  defp parse_project_type(_), do: {:error, "invalid project_type"}

  defp parse_target_os("macos"), do: {:ok, :macos}
  defp parse_target_os("windows"), do: {:ok, :windows}
  defp parse_target_os(:macos), do: {:ok, :macos}
  defp parse_target_os(:windows), do: {:ok, :windows}
  defp parse_target_os(_), do: {:error, "invalid target_os"}

  defp validate_known(ids) do
    unknown = Enum.reject(ids, &module_for/1)

    if unknown == [],
      do: :ok,
      else: {:error, "unknown features: #{Enum.join(unknown, ", ")}"}
  end

  defp validate_availability(ids, project_type) do
    invalid =
      Enum.filter(ids, fn id ->
        case module_for(id) do
          nil -> true
          mod -> not available?(mod.available_for(), project_type)
        end
      end)

    if invalid == [],
      do: :ok,
      else: {:error, "features not available for project type: #{Enum.join(invalid, ", ")}"}
  end

  defp available?(:both, _), do: true
  defp available?(type, type), do: true
  defp available?(_, _), do: false

  defp ash_available?(Elixirmachine.Features.Ash, config) do
    Map.get(config, "storage_backend", "postgres") == "postgres"
  end

  defp ash_available?(_, _), do: true

  defp validate_conflicts(ids) do
    conflicts =
      Enum.flat_map(ids, fn id ->
        mod = module_for(id)

        mod.conflicts_with()
        |> Enum.map(&Atom.to_string/1)
        |> Enum.filter(&(&1 in ids))
        |> Enum.map(fn other -> {id, other} end)
      end)

    if conflicts == [],
      do: :ok,
      else: {:error, "conflicting features: #{inspect(conflicts)}"}
  end

  defp stringify_keys(map) when is_map(map) do
    Map.new(map, fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), stringify_value(v)}
      {k, v} -> {k, stringify_value(v)}
    end)
  end

  defp stringify_value(v) when is_map(v), do: stringify_keys(v)
  defp stringify_value(v), do: v
end
