defmodule ElixirmachineWeb.Configurator.Wizard.StepAddons do
  @moduledoc false
  use Phoenix.Component

  import ElixirmachineWeb.Configurator.SectionCard

  alias Elixirmachine.Config.Wizard

  attr :active_tab, :atom, required: true
  attr :section_packages, :map, required: true
  attr :features, :list, required: true
  attr :visible_sections, :list, required: true

  def step_addons(assigns) do
    tabs =
      Wizard.addon_sections()
      |> Enum.filter(&(&1 in assigns.visible_sections))

    assigns = assign(assigns, :tabs, tabs)

    ~H"""
    <div class="space-y-6">
      <div>
        <h3 class="text-lg font-semibold text-base-content">Add-ons</h3>
        <p class="text-sm text-base-content/70 mt-1">
          Optional packages grouped by category — like start.spring.io dependencies.
        </p>
      </div>

      <div class="tabs tabs-bordered">
        <%= for section <- @tabs do %>
          <button
            type="button"
            class={["tab", @active_tab == section && "tab-active"]}
            phx-click="wizard_tab"
            phx-value-tab={Atom.to_string(section)}
          >
            {Wizard.addon_section_label(section)}
          </button>
        <% end %>
      </div>

      <.package_checkboxes
        packages={Map.get(@section_packages, @active_tab, [])}
        features={@features}
      />
    </div>
    """
  end
end
