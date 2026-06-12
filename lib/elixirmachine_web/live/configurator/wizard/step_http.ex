defmodule ElixirmachineWeb.Configurator.Wizard.StepHttp do
  @moduledoc false
  use Phoenix.Component

  import ElixirmachineWeb.Configurator.Wizard.StepErrors, only: [step_error: 1]

  attr :form, :any, required: true
  attr :project_type, :string, required: true
  attr :errors, :map, default: %{}

  def step_http(assigns) do
    ~H"""
    <div class="space-y-6">
      <div>
        <h3 class="text-lg font-semibold text-base-content">HTTP / API</h3>
        <p class="text-sm text-base-content/70 mt-1">
          Configure outbound HTTP clients and JSON API endpoints.
        </p>
      </div>

      <div
        :if={@project_type == "phoenix_api"}
        class="rounded-[var(--rounded-box)] border border-base-300 bg-base-200/40 p-4"
      >
        <span class="badge badge-neutral badge-sm">included</span>
        <span class="ml-2 font-medium">Phoenix JSON API</span>
        <p class="text-sm text-base-content/70 mt-2">
          Bandit, Phoenix, Req, and Jason are included with the Phoenix API scaffold.
        </p>
        <input type="hidden" name="generation[configuration][include_api]" value="true" />
        <input type="hidden" name="generation[configuration][http_client]" value="req" />
      </div>

      <div :if={@project_type != "phoenix_api"} class="space-y-4">
        <fieldset class="space-y-3">
          <legend class="text-sm font-medium">Expose HTTP/API endpoints?</legend>
          <label class="package-row flex items-center gap-3 rounded-[var(--rounded-btn)] border border-base-300 p-3 cursor-pointer card-interactive">
            <input
              type="radio"
              name="generation[configuration][include_api]"
              value="true"
              checked={config_value(@form, "include_api") == "true"}
              class="radio radio-primary radio-sm"
            />
            <span>Yes — include HTTP/API endpoints</span>
          </label>
          <label class="package-row flex items-center gap-3 rounded-[var(--rounded-btn)] border border-base-300 p-3 cursor-pointer card-interactive">
            <input
              type="radio"
              name="generation[configuration][include_api]"
              value="false"
              checked={config_value(@form, "include_api") == "false"}
              class="radio radio-primary radio-sm"
            />
            <span>No — skip HTTP/API for now</span>
          </label>
        </fieldset>
        <.step_error message={Map.get(@errors, :include_api)} />

        <fieldset :if={config_value(@form, "include_api") == "true"} class="space-y-3">
          <legend class="text-sm font-medium">HTTP client</legend>
          <p class="text-sm text-base-content/70">
            Req is included by default with Phoenix scaffolds.
          </p>
          <label class="package-row flex items-center gap-3 rounded-[var(--rounded-btn)] border border-base-300 p-3 cursor-pointer card-interactive">
            <input
              type="radio"
              name="generation[configuration][http_client]"
              value="req"
              checked={config_value(@form, "http_client") in ["req", "none", ""]}
              class="radio radio-primary radio-sm"
            />
            <span>Req only (default)</span>
          </label>
          <label class="package-row flex items-center gap-3 rounded-[var(--rounded-btn)] border border-base-300 p-3 cursor-pointer card-interactive">
            <input
              type="radio"
              name="generation[configuration][http_client]"
              value="finch"
              checked={config_value(@form, "http_client") == "finch"}
              class="radio radio-primary radio-sm"
            />
            <span>Add Finch</span>
          </label>
        </fieldset>
      </div>
    </div>
    """
  end

  defp config_value(form, key) do
    case form[:configuration] do
      %{value: value} when is_map(value) -> Map.get(value, key, "")
      _ -> ""
    end
  end
end
