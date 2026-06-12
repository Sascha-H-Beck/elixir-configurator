defmodule ElixirmachineWeb.Configurator.Wizard.StepProject do
  @moduledoc false
  use Phoenix.Component

  import ElixirmachineWeb.Configurator.Wizard.StepErrors, only: [step_error: 1]

  attr :form, :any, required: true
  attr :errors, :map, default: %{}

  def step_project(assigns) do
    ~H"""
    <div class="space-y-6">
      <div>
        <h3 class="text-lg font-semibold text-base-content">Project metadata</h3>
        <p class="text-sm text-base-content/70 mt-1">
          Name your project and choose the scaffold type.
        </p>
      </div>

      <fieldset class="fieldset mb-2">
        <label class="label"><span class="label-text font-medium">Project name</span></label>
        <input
          type="text"
          name="generation[project_name]"
          value={@form[:project_name].value}
          placeholder="my_app"
          class={[
            "input input-bordered w-full",
            Map.has_key?(@errors, :project_name) && "input-error"
          ]}
        />
        <p class="label-text-alt text-base-content/60 mt-1">
          Lowercase letters, numbers, and underscores only (e.g. my_app).
        </p>
        <.step_error message={Map.get(@errors, :project_name)} />
      </fieldset>

      <fieldset class="fieldset mb-2">
        <label class="label"><span class="label-text font-medium">Project type</span></label>
        <div class="grid gap-3 sm:grid-cols-3">
          <%= for {label, value, desc} <- project_type_cards() do %>
            <label class={[
              "package-row cursor-pointer rounded-[var(--rounded-box)] border p-4 card-interactive",
              @form[:project_type].value == value && "border-primary ring-2 ring-primary/30",
              @form[:project_type].value != value && "border-base-300"
            ]}>
              <input
                type="radio"
                name="generation[project_type]"
                value={value}
                checked={@form[:project_type].value == value}
                class="radio radio-primary radio-sm"
              />
              <span class="mt-2 block font-medium">{label}</span>
              <span class="block text-sm text-base-content/70 mt-1">{desc}</span>
            </label>
          <% end %>
        </div>
      </fieldset>

      <div class="grid gap-4 md:grid-cols-2">
        <fieldset class="fieldset mb-2">
          <label class="label"><span class="label-text font-medium">Target OS</span></label>
          <select name="generation[target_os]" class="select select-bordered w-full">
            <option value="macos" selected={@form[:target_os].value == "macos"}>macOS (.sh)</option>
            <option value="windows" selected={@form[:target_os].value == "windows"}>
              Windows (.bat)
            </option>
          </select>
        </fieldset>
        <fieldset class="fieldset mb-2">
          <label class="label"><span class="label-text font-medium">Output path</span></label>
          <input
            type="text"
            name="generation[output_path]"
            value={@form[:output_path].value}
            placeholder={output_path_placeholder(@form[:target_os].value)}
            class={[
              "input input-bordered w-full",
              Map.has_key?(@errors, :output_path) && "input-error"
            ]}
          />
          <p class="label-text-alt text-base-content/60 mt-1">
            Required — folder where the generated project will be created.
          </p>
          <.step_error message={Map.get(@errors, :output_path)} />
        </fieldset>
      </div>
    </div>
    """
  end

  defp project_type_cards do
    [
      {"Standalone OTP", "standalone_otp", "Plain Elixir app without Phoenix"},
      {"Phoenix API", "phoenix_api", "JSON API without LiveView"},
      {"Phoenix LiveView", "phoenix_liveview", "Full web app with LiveView"}
    ]
  end

  defp output_path_placeholder("windows"), do: "C:\\Projects\\my_app"
  defp output_path_placeholder(_), do: "~/Projects/my_app"
end
