defmodule ElixirmachineWeb.Configurator.Wizard.StepStorage do
  @moduledoc false
  use Phoenix.Component

  import ElixirmachineWeb.Configurator.Wizard.StepErrors, only: [step_error: 1]

  attr :form, :any, required: true
  attr :project_type, :string, required: true
  attr :features, :list, required: true
  attr :errors, :map, default: %{}

  def step_storage(assigns) do
    ~H"""
    <div class="space-y-6">
      <div>
        <h3 class="text-lg font-semibold text-base-content">Storage</h3>
        <p class="text-sm text-base-content/70 mt-1">
          Choose how your application persists data.
        </p>
      </div>

      <div :if={@project_type in ["phoenix_api", "phoenix_liveview"]} class="space-y-3">
        <div class="rounded-[var(--rounded-box)] border border-base-300 bg-base-200/40 p-4">
          <span class="badge badge-neutral badge-sm">included</span>
          <span class="ml-2 font-medium">Ecto + PostgreSQL</span>
          <p class="text-sm text-base-content/70 mt-2">
            Phoenix projects include PostgreSQL via the scaffold. Docker Compose is generated when applicable.
          </p>
        </div>
        <input type="hidden" name="generation[configuration][storage_backend]" value="postgres" />
        <.ash_option form={@form} features={@features} />
      </div>

      <div :if={@project_type == "standalone_otp"} class="space-y-4">
        <fieldset class="space-y-3">
          <legend class="text-sm font-medium">Storage backend</legend>
          <%= for {value, label, desc} <- storage_options() do %>
            <label class={[
              "package-row flex items-start gap-3 rounded-[var(--rounded-btn)] border p-3 cursor-pointer card-interactive",
              config_value(@form, "storage_backend") == value && "border-primary",
              config_value(@form, "storage_backend") != value && "border-base-300"
            ]}>
              <input
                type="radio"
                name="generation[configuration][storage_backend]"
                value={value}
                checked={config_value(@form, "storage_backend") == value}
                class="radio radio-primary mt-1"
              />
              <span>
                <span class="font-medium">{label}</span>
                <span class="block text-sm text-base-content/70 mt-1">{desc}</span>
              </span>
            </label>
          <% end %>
        </fieldset>
        <.step_error message={Map.get(@errors, :storage_backend)} />
        <.ash_option
          :if={config_value(@form, "storage_backend") == "postgres"}
          form={@form}
          features={@features}
        />
      </div>
    </div>
    """
  end

  attr :form, :any, required: true
  attr :features, :list, required: true

  defp ash_option(assigns) do
    ~H"""
    <label class="package-row flex items-start gap-3 rounded-[var(--rounded-btn)] border border-base-300 p-3 cursor-pointer card-interactive">
      <input
        type="checkbox"
        name="generation[features][]"
        value="ash"
        checked={"ash" in @features}
        class="checkbox checkbox-primary mt-1"
      />
      <span>
        <span class="font-medium">Ash Framework</span>
        <span class="block text-sm text-base-content/70 mt-1">
          Optional domain layer with AshPostgres data layer.
        </span>
      </span>
    </label>
    """
  end

  defp storage_options do
    [
      {"none", "No database", "Plain OTP app without Ecto or persistent storage"},
      {"postgres", "PostgreSQL", "Ecto SQL with Postgrex and Docker Compose"},
      {"ets", "ETS (in-memory)", "Ecto with the ETS adapter for in-memory data"}
    ]
  end

  defp config_value(form, key) do
    case form[:configuration] do
      %{value: value} when is_map(value) -> Map.get(value, key, "")
      _ -> ""
    end
  end
end
