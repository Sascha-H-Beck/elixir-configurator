defmodule ElixirmachineWeb.Configurator.Wizard.StepErrors do
  @moduledoc false
  use Phoenix.Component

  attr :message, :string, default: nil

  def step_error(assigns) do
    ~H"""
    <p :if={@message} class="label-text-alt text-error mt-1">{@message}</p>
    """
  end

  attr :errors, :map, default: %{}

  def step_errors_summary(assigns) do
    ~H"""
    <div :if={map_size(@errors) > 0} class="alert alert-error mt-4 py-3">
      <ul class="list-disc list-inside text-sm space-y-1">
        <li :for={{_field, message} <- @errors}>{message}</li>
      </ul>
    </div>
    """
  end
end
