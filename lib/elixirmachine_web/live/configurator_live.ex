defmodule ElixirmachineWeb.ConfiguratorLive do
  use ElixirmachineWeb, :live_view

  import ElixirmachineWeb.Configurator.Wizard.Nav
  import ElixirmachineWeb.Configurator.Wizard.StepAddons
  import ElixirmachineWeb.Configurator.Wizard.StepErrors
  import ElixirmachineWeb.Configurator.Wizard.StepFrontend
  import ElixirmachineWeb.Configurator.Wizard.StepHttp
  import ElixirmachineWeb.Configurator.Wizard.StepIndicator
  import ElixirmachineWeb.Configurator.Wizard.StepProject
  import ElixirmachineWeb.Configurator.Wizard.StepReview
  import ElixirmachineWeb.Configurator.Wizard.StepStorage

  alias Elixirmachine.Config.{DepCatalog, SectionVisibility, Wizard}
  alias Elixirmachine.Config.Wizard.Sync
  alias Elixirmachine.Features.Catalog
  alias Elixirmachine.Generations

  @impl true
  def mount(_params, _session, socket) do
    attrs = default_attrs()

    {:ok,
     socket
     |> assign(:page_title, "elixirmachine")
     |> assign(:result, nil)
     |> assign(:preview, nil)
     |> assign(:error, nil)
     |> assign(:wizard_step, :project)
     |> assign(:max_step_reached, 0)
     |> assign(:active_addon_tab, :auth)
     |> assign(:step_errors, %{})
     |> assign_form(attrs)
     |> assign_resolution(attrs)
     |> assign_wizard_steps()}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div>
        <h1 class="text-2xl font-bold text-base-content">Project configurator</h1>
        <p class="text-sm text-base-content/60 mt-1">
          Step through your stack choices, then generate a downloadable build script.
        </p>
      </div>

      <.step_indicator
        steps={@wizard_steps}
        current={@wizard_step}
        max_reached={@max_step_reached}
      />

      <div class="card bg-base-100 border border-base-300 shadow-sm">
        <div class="card-body">
          <.form for={@form} id="configurator-form" phx-change="validate" phx-submit="form_submit">
            <div>
              <.step_project
                :if={@wizard_step == :project}
                form={@form}
                errors={@step_errors}
              />

              <.step_storage
                :if={@wizard_step == :storage}
                form={@form}
                project_type={@form[:project_type].value}
                features={@form[:features].value || []}
                errors={@step_errors}
              />

              <.step_http
                :if={@wizard_step == :http}
                form={@form}
                project_type={@form[:project_type].value}
                errors={@step_errors}
              />

              <.step_frontend
                :if={@wizard_step == :frontend}
                packages={Map.get(@section_packages, :liveview_frontend, [])}
                features={@form[:features].value || []}
              />

              <.step_addons
                :if={@wizard_step == :addons}
                active_tab={@active_addon_tab}
                section_packages={@addon_packages}
                features={@form[:features].value || []}
                visible_sections={@addon_sections}
              />

              <.step_review
                :if={@wizard_step == :review}
                form={@form}
                resolved_preview={@resolved_preview}
                required_additions={@required_additions}
                can_generate={@can_generate}
                resolution_error={@resolution_error}
              />
            </div>

            <.step_errors_summary errors={@step_errors} />

            <.wizard_nav
              :if={@wizard_step != :review}
              show_back={@wizard_step != :project}
              show_next={true}
              next_label={if(@wizard_step == :addons, do: "Review", else: "Next")}
            />
          </.form>
        </div>
      </div>

      <div :if={@error} class="alert alert-error"><span>{@error}</span></div>

      <div :if={@preview} class="card bg-base-100 border border-base-300 shadow-sm">
        <div class="card-body">
          <h3 class="card-title text-sm">Command preview</h3>
          <pre class="bg-base-200 p-4 rounded-[var(--rounded-box)] overflow-x-auto text-sm whitespace-pre-wrap">{@preview}</pre>
        </div>
      </div>

      <div :if={@result} class="card bg-base-100 border border-success shadow-sm">
        <div class="card-body space-y-3">
          <h3 class="card-title text-success">Generation ready</h3>
          <p class="text-sm text-base-content/70">
            Copy this API key now — it is shown only once per generation.
          </p>
          <div class="mockup-code">
            <pre data-prefix=">"><code>{@result.api_key}</code></pre>
          </div>
          <a
            class="btn btn-accent"
            href={~p"/generations/#{@result.generation.id}/script?api_key=#{@result.api_key}"}
          >
            Download {@result.generation.script_filename}
          </a>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("validate", params, socket) do
    {params, socket} = apply_form_params(params, socket)

    {:noreply,
     socket
     |> assign(:step_errors, %{})
     |> assign_form(params)
     |> assign_resolution(params)}
  end

  @impl true
  def handle_event("form_submit", %{"wizard_action" => "next"} = event_params, socket) do
    {params, socket} = apply_form_params(event_params, socket)

    socket =
      socket
      |> assign_form(params)
      |> assign_resolution(params)

    case Wizard.validate_step(socket.assigns.wizard_step, params) do
      :ok ->
        next = Wizard.next_step(socket.assigns.wizard_steps, socket.assigns.wizard_step)
        idx = Wizard.step_index(socket.assigns.wizard_steps, next) || 0

        {:noreply,
         socket
         |> assign(:wizard_step, next)
         |> assign(:max_step_reached, max(socket.assigns.max_step_reached, idx))
         |> assign(:step_errors, %{})}

      {:error, errors} ->
        {:noreply, assign(socket, :step_errors, errors)}
    end
  end

  def handle_event("form_submit", params, socket) do
    {params, socket} = apply_form_params(params, socket)

    socket =
      socket
      |> assign_form(params)
      |> assign_resolution(params)

    do_generate(params, socket)
  end

  @impl true
  def handle_event("wizard_back", _params, socket) do
    prev = Wizard.prev_step(socket.assigns.wizard_steps, socket.assigns.wizard_step)

    {:noreply,
     socket
     |> assign(:wizard_step, prev)
     |> assign(:step_errors, %{})}
  end

  @impl true
  def handle_event("wizard_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_addon_tab, String.to_existing_atom(tab))}
  end

  @impl true
  def handle_event("preview", _params, socket) do
    if socket.assigns.can_generate do
      case Generations.preview(form_attrs(socket.assigns.form)) do
        {:ok, content, _filename} ->
          lines =
            content
            |> String.split("\n")
            |> Enum.filter(&String.contains?(&1, "mix"))
            |> Enum.join("\n")

          {:noreply, assign(socket, preview: lines, error: nil)}

        {:error, message} ->
          {:noreply, assign(socket, preview: nil, error: message)}
      end
    else
      {:noreply,
       assign(socket, preview: nil, error: "Accept all required packages before previewing.")}
    end
  end

  @impl true
  def handle_event("generate", %{"generation" => params}, socket) do
    do_generate(params, socket)
  end

  defp do_generate(params, socket) do
    if socket.assigns.can_generate do
      params = params |> normalize_params() |> sync_acceptance()

      case Generations.create(params) do
        {:ok, generation, api_key} ->
          {:noreply,
           socket
           |> assign(:result, %{generation: generation, api_key: api_key})
           |> assign(:error, nil)
           |> assign(:preview, nil)
           |> assign_form(params)
           |> assign_resolution(params)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, error: error_message(changeset), result: nil)}

        {:error, message} when is_binary(message) ->
          {:noreply, assign(socket, error: message, result: nil)}
      end
    else
      {:noreply,
       assign(socket, error: "Accept all required packages before generating.", result: nil)}
    end
  end

  defp assign_form(socket, params) do
    assign(socket, form: to_form(normalize_params(params), as: :generation))
  end

  defp assign_wizard_steps(socket) do
    type = project_type_atom(socket.assigns.form[:project_type].value)
    assign(socket, :wizard_steps, Wizard.steps(type))
  end

  defp assign_resolution(socket, params) do
    project_type = project_type_atom(params["project_type"])
    configuration = Map.get(params, "configuration", %{})

    case Catalog.resolve_configuration(project_type, params) do
      {:ok, resolution} ->
        visible = SectionVisibility.visible_sections(project_type, configuration)

        section_packages =
          Map.new(visible, fn section ->
            packages =
              section
              |> Catalog.packages_for_section(project_type, configuration)
              |> reject_wizard_managed()

            {section, packages}
          end)

        addon_sections =
          Wizard.addon_sections() |> Enum.filter(&(&1 in visible))

        addon_packages =
          Map.new(addon_sections, fn section ->
            {section, Map.get(section_packages, section, [])}
          end)

        socket
        |> assign(:visible_sections, visible)
        |> assign(:section_packages, section_packages)
        |> assign(:addon_sections, addon_sections)
        |> assign(:addon_packages, addon_packages)
        |> assign(:required_additions, resolution.required_details)
        |> assign(:resolved_preview, resolution.resolved)
        |> assign(:can_generate, resolution.can_generate)
        |> assign(:resolution_error, nil)
        |> assign_wizard_steps()
        |> maybe_reset_addon_tab(addon_sections)

      {:error, message} ->
        socket
        |> assign(:visible_sections, [])
        |> assign(:section_packages, %{})
        |> assign(:addon_sections, [])
        |> assign(:addon_packages, %{})
        |> assign(:required_additions, [])
        |> assign(:resolved_preview, [])
        |> assign(:can_generate, false)
        |> assign(:resolution_error, message)
        |> assign_wizard_steps()
    end
  end

  defp maybe_reset_addon_tab(socket, addon_sections) do
    if socket.assigns.active_addon_tab in addon_sections do
      socket
    else
      assign(socket, :active_addon_tab, List.first(addon_sections, :auth))
    end
  end

  defp reject_wizard_managed(packages) do
    managed = MapSet.new(DepCatalog.wizard_managed_ids())

    Enum.reject(packages, fn pkg -> pkg.id in managed end)
  end

  defp apply_form_params(params, socket) do
    prev_type = socket.assigns.form[:project_type].value
    merged = incoming_generation_params(params, socket)
    new_type = Map.get(merged, "project_type", prev_type)

    {merged, socket} =
      if prev_type != new_type do
        {merged
         |> Map.put("configuration", SectionVisibility.default_configuration(new_type))
         |> Map.put("features", [])
         |> Map.put("accepted_required", []),
         socket
         |> assign(:wizard_step, :project)
         |> assign(:max_step_reached, 0)}
      else
        {merged, socket}
      end

    params = merged |> normalize_params() |> sync_acceptance()
    {params, socket}
  end

  defp incoming_generation_params(params, socket) do
    base = form_attrs(socket.assigns.form)
    incoming = params |> Map.get("generation", %{}) |> stringify_map()

    merged =
      Map.merge(base, incoming, fn
        "configuration", base_config, incoming_config ->
          base_config
          |> stringify_map()
          |> Map.merge(stringify_map(incoming_config))

        _key, _base_val, incoming_val ->
          incoming_val
      end)

    if features_target?(params) and not Map.has_key?(incoming, "features") do
      Map.put(merged, "features", [])
    else
      merged
    end
  end

  defp features_target?(%{"_target" => ["generation", "features" | _]}), do: true
  defp features_target?(_), do: false

  defp sync_acceptance(params) do
    project_type = project_type_atom(params["project_type"])
    accepted = Map.get(params, "accepted_required", [])
    params_for_resolution = Map.delete(params, "accepted_required")

    case Catalog.resolve_configuration(project_type, params_for_resolution) do
      {:ok, resolution} ->
        accepted =
          if accepted == [] and resolution.required_additions != [] do
            resolution.required_additions
          else
            accepted
          end

        adjusted =
          Catalog.adjust_selected_for_acceptance(
            resolution.selected,
            accepted,
            resolution.required_additions
          )

        params
        |> Map.put("features", adjusted)
        |> Map.put("accepted_required", accepted)

      _ ->
        params
    end
  end

  defp default_attrs do
    project_type = "phoenix_liveview"

    %{
      "project_name" => "",
      "project_type" => project_type,
      "target_os" => "macos",
      "output_path" => "",
      "features" => [],
      "accepted_required" => [],
      "configuration" => SectionVisibility.default_configuration(project_type)
    }
    |> Sync.sync_all()
  end

  defp normalize_params(params) do
    project_type = Map.get(params, "project_type", "phoenix_liveview")

    configuration =
      params
      |> Map.get("configuration", %{})
      |> stringify_map()
      |> then(&Map.merge(SectionVisibility.default_configuration(project_type), &1))

    features =
      params
      |> Map.get("features", [])
      |> List.wrap()
      |> Enum.reject(&(&1 == ""))

    accepted_required =
      params
      |> Map.get("accepted_required", [])
      |> List.wrap()
      |> Enum.reject(&(&1 == ""))

    params
    |> Map.put("configuration", configuration)
    |> Map.put("features", features)
    |> Map.put("accepted_required", accepted_required)
    |> Map.put_new("project_type", project_type)
    |> Map.put_new("target_os", "macos")
    |> Sync.sync_all()
  end

  defp stringify_map(map) when is_map(map) do
    Map.new(map, fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), v}
      {k, v} -> {k, v}
    end)
  end

  defp form_attrs(form) do
    %{
      "project_name" => form[:project_name].value,
      "project_type" => form[:project_type].value,
      "target_os" => form[:target_os].value,
      "output_path" => form[:output_path].value,
      "features" => form[:features].value || [],
      "accepted_required" => form[:accepted_required].value || [],
      "configuration" => config_map(form)
    }
  end

  defp config_map(form) do
    case form[:configuration] do
      %{value: value} when is_map(value) -> value
      _ -> %{}
    end
  end

  defp project_type_atom("standalone_otp"), do: :standalone_otp
  defp project_type_atom("phoenix_api"), do: :phoenix_api
  defp project_type_atom("phoenix_liveview"), do: :phoenix_liveview
  defp project_type_atom(_), do: :phoenix_liveview

  defp error_message(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map_join("; ", fn {field, errors} ->
      "#{field}: #{Enum.join(errors, ", ")}"
    end)
  end
end
