defmodule ElixirmachineWeb.Configurator.Wizard.StepIndicator do
  @moduledoc false
  use Phoenix.Component

  import ElixirmachineWeb.CoreComponents, only: [icon: 1]

  alias Elixirmachine.Config.Wizard

  attr :steps, :list, required: true
  attr :current, :atom, required: true
  attr :max_reached, :integer, default: 0

  def step_indicator(assigns) do
    ~H"""
    <ul class="steps steps-horizontal w-full overflow-x-auto pb-2">
      <%= for {step, idx} <- Enum.with_index(@steps) do %>
        <li class={[
          "step",
          idx <= @max_reached && "step-primary",
          step == @current && "font-semibold"
        ]}>
          <span class="flex items-center gap-1.5 text-xs">
            <.icon name={step_icon(step)} class="size-3.5" />
            {step_label(step)}
          </span>
        </li>
      <% end %>
    </ul>
    """
  end

  defp step_label(step), do: Wizard.step_label(step)

  defp step_icon(:project), do: "hero-cube"
  defp step_icon(:storage), do: "hero-circle-stack"
  defp step_icon(:http), do: "hero-globe-alt"
  defp step_icon(:frontend), do: "hero-paint-brush"
  defp step_icon(:addons), do: "hero-puzzle-piece"
  defp step_icon(:review), do: "hero-check-badge"
  defp step_icon(_), do: "hero-cube"
end
