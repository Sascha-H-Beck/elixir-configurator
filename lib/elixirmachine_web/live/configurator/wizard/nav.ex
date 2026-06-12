defmodule ElixirmachineWeb.Configurator.Wizard.Nav do
  @moduledoc false
  use Phoenix.Component

  attr :show_back, :boolean, default: false
  attr :show_next, :boolean, default: true
  attr :next_label, :string, default: "Next"
  attr :next_disabled, :boolean, default: false

  def wizard_nav(assigns) do
    ~H"""
    <div class="card-actions justify-between mt-6 gap-2">
      <button
        :if={@show_back}
        type="button"
        class="btn btn-outline"
        phx-click="wizard_back"
      >
        Back
      </button>
      <div :if={not @show_back}></div>
      <button
        :if={@show_next}
        type="submit"
        name="wizard_action"
        value="next"
        class="btn btn-accent"
        disabled={@next_disabled}
      >
        {@next_label}
      </button>
    </div>
    """
  end
end
