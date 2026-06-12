defmodule Elixirmachine.Config.Wizard.Sync do
  @moduledoc false

  alias Elixirmachine.Config.DepCatalog

  def sync_all(params) when is_map(params) do
    params
    |> sync_storage()
    |> sync_http()
    |> drop_wizard_managed_from_features()
  end

  def derived_feature_ids(project_type, configuration) when is_atom(project_type) do
    project_type
    |> Atom.to_string()
    |> derived_feature_ids(configuration)
  end

  def derived_feature_ids(project_type, configuration) when is_binary(project_type) do
    configuration = stringify_map(configuration)

    storage_ids(project_type, configuration) ++ http_ids(project_type, configuration)
  end

  defp sync_storage(params) do
    project_type = Map.get(params, "project_type", "phoenix_liveview")
    config = config_map(params)
    backend = storage_backend(project_type, config)

    config =
      config
      |> Map.put("storage_backend", backend)
      |> Map.put("include_database", database_enabled?(backend))
      |> Map.put("database_type", "postgres")

    params
    |> Map.put("configuration", config)
    |> drop_ash_unless_postgres(backend)
  end

  defp sync_http(params) do
    project_type = Map.get(params, "project_type", "phoenix_liveview")
    config = config_map(params)
    {include_api, http_client} = http_settings(project_type, config)

    config =
      config
      |> Map.put("include_api", bool_string(include_api))
      |> Map.put("http_client", if(include_api, do: http_client, else: "none"))

    Map.put(params, "configuration", config)
  end

  defp drop_wizard_managed_from_features(params) do
    managed = MapSet.new(DepCatalog.wizard_managed_ids())

    features =
      params
      |> feature_list()
      |> Enum.reject(&(&1 in managed))

    Map.put(params, "features", features)
  end

  defp drop_ash_unless_postgres(params, "postgres"), do: params

  defp drop_ash_unless_postgres(params, _backend) do
    features = feature_list(params) |> Enum.reject(&(&1 == "ash"))
    Map.put(params, "features", features)
  end

  defp storage_ids("phoenix_api", _config), do: ["ecto_postgres"]
  defp storage_ids("phoenix_liveview", _config), do: ["ecto_postgres"]

  defp storage_ids("standalone_otp", %{"storage_backend" => "postgres"}), do: ["ecto_postgres"]
  defp storage_ids("standalone_otp", %{"storage_backend" => "ets"}), do: ["ecto_ets"]
  defp storage_ids("standalone_otp", _), do: []

  defp storage_ids(_, _), do: []

  defp http_ids(_project_type, %{"include_api" => "true", "http_client" => "finch"}),
    do: ["finch"]

  defp http_ids(_, _), do: []

  defp storage_backend("phoenix_api", _config), do: "postgres"
  defp storage_backend("phoenix_liveview", _config), do: "postgres"

  defp storage_backend("standalone_otp", config) do
    case Map.get(config, "storage_backend", "none") do
      backend when backend in ["none", "postgres", "ets"] -> backend
      _ -> "none"
    end
  end

  defp storage_backend(_, config), do: Map.get(config, "storage_backend", "none")

  defp database_enabled?("none"), do: "false"
  defp database_enabled?(_), do: "true"

  defp http_settings("phoenix_api", config) do
    {true, normalize_http_client(Map.get(config, "http_client", "req"))}
  end

  defp http_settings("phoenix_liveview", config) do
    include_api = Map.get(config, "include_api", "false") == "true"
    {include_api, normalize_http_client(Map.get(config, "http_client", "req"))}
  end

  defp http_settings("standalone_otp", config) do
    include_api = Map.get(config, "include_api", "false") == "true"
    {include_api, normalize_http_client(Map.get(config, "http_client", "req"))}
  end

  defp http_settings(_, config) do
    {Map.get(config, "include_api", "false") == "true",
     normalize_http_client(Map.get(config, "http_client", "req"))}
  end

  defp normalize_http_client(value) when is_list(value),
    do: value |> List.last() |> normalize_http_client()

  defp normalize_http_client("finch"), do: "finch"
  defp normalize_http_client(_), do: "req"

  defp config_map(params) do
    params
    |> Map.get("configuration", %{})
    |> stringify_map()
  end

  defp feature_list(params) do
    params
    |> Map.get("features", [])
    |> List.wrap()
    |> Enum.map(&to_string/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
  end

  defp stringify_map(map) when is_map(map) do
    Map.new(map, fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), to_string(v)}
      {k, v} -> {k, to_string(v)}
    end)
  end

  defp bool_string(true), do: "true"
  defp bool_string(false), do: "false"
end
