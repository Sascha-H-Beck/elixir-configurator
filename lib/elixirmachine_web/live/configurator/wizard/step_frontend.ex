defmodule ElixirmachineWeb.Configurator.Wizard.StepFrontend do
  @moduledoc false
  use Phoenix.Component

  import ElixirmachineWeb.Configurator.SectionCard

  attr :packages, :list, required: true
  attr :features, :list, required: true

  def step_frontend(assigns) do
    ~H"""
    <div class="space-y-6">
      <div>
        <h3 class="text-lg font-semibold text-base-content">Frontend</h3>
        <p class="text-sm text-base-content/70 mt-1">
          Tailwind and Heroicons are included. Choose an optional UI component library.
        </p>
      </div>
      <.implicit_badges badges={Elixirmachine.Config.DepCatalog.liveview_implicit_badges()} />
      <.package_checkboxes packages={@packages} features={@features} />
    </div>
    """
  end
end
