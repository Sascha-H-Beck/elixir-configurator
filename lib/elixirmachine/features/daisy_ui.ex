defmodule Elixirmachine.Features.DaisyUi do
  @moduledoc false
  @behaviour Elixirmachine.Features.Behaviour

  @impl true
  def id, do: :daisy_ui
  @impl true
  def label, do: "daisyUI"
  @impl true
  def description, do: "Tailwind CSS with daisyUI component library."
  @impl true
  def requires, do: [:liveview]
  @impl true
  def conflicts_with, do: []
  @impl true
  def available_for, do: :phoenix_liveview
  @impl true
  def coming_soon?, do: false

  @impl true
  def igniter_commands(_context) do
    [
      %{type: :shell, command: "cd assets && npm install -D daisyui@latest"},
      %{
        type: :shell,
        command:
          "mix igniter.add_to_file assets/tailwind.config.js \"plugins: [require('daisyui')]\""
      }
    ]
  end

  @impl true
  def template_files(_context), do: []
end
