defmodule ElixirmachineWeb.Configurator.Wizard.StepReview do
  @moduledoc false
  use Phoenix.Component

  attr :resolved_preview, :list, required: true
  attr :required_additions, :list, required: true
  attr :form, :any, required: true
  attr :can_generate, :boolean, required: true
  attr :resolution_error, :string, default: nil

  def step_review(assigns) do
    ~H"""
    <div class="space-y-6">
      <div>
        <h3 class="text-lg font-semibold text-base-content">Review</h3>
        <p class="text-sm text-base-content/70 mt-1">
          Confirm your selection before generating the build script.
        </p>
      </div>

      <dl class="grid gap-2 text-sm sm:grid-cols-2">
        <div>
          <dt class="text-base-content/70">Project</dt><dd class="font-medium">
            {@form[:project_name].value}
          </dd>
        </div>
        <div>
          <dt class="text-base-content/70">Type</dt><dd class="font-medium">
            {@form[:project_type].value}
          </dd>
        </div>
        <div>
          <dt class="text-base-content/70">Target OS</dt><dd class="font-medium">
            {@form[:target_os].value}
          </dd>
        </div>
        <div>
          <dt class="text-base-content/70">Output</dt><dd class="font-medium break-all">
            {@form[:output_path].value}
          </dd>
        </div>
      </dl>

      <div
        :if={@required_additions != []}
        class="rounded-[var(--rounded-box)] border border-warning/40 bg-warning/10 p-4"
      >
        <p class="text-sm font-semibold mb-3">Required additions</p>
        <div class="grid gap-2">
          <%= for req <- @required_additions do %>
            <label class="package-row label cursor-pointer justify-start gap-3 py-1">
              <input
                type="checkbox"
                name="generation[accepted_required][]"
                value={req.id}
                checked={req.id in (@form[:accepted_required].value || [])}
                class="checkbox checkbox-warning"
              />
              <span class="label-text">
                <span class="font-medium">{req.label}</span>
              </span>
            </label>
          <% end %>
        </div>
      </div>

      <div :if={@resolved_preview != []}>
        <p class="text-sm font-semibold mb-2">Resolved packages</p>
        <div class="flex flex-wrap gap-2">
          <span :for={id <- @resolved_preview} class="badge badge-outline border-base-300">{id}</span>
        </div>
      </div>

      <div :if={@resolution_error} class="alert alert-warning py-2">
        <span class="text-sm">{@resolution_error}</span>
      </div>

      <div class="card-actions justify-end gap-2">
        <button type="button" class="btn btn-outline" phx-click="preview">Preview commands</button>
        <button type="submit" class="btn btn-accent" disabled={not @can_generate}>Generate</button>
      </div>
    </div>
    """
  end
end
