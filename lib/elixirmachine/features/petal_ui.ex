defmodule Elixirmachine.Features.PetalUi do
  @moduledoc false
  @behaviour Elixirmachine.Features.Behaviour

  @impl true
  def id, do: :petal_ui
  @impl true
  def label, do: "Petal Components"
  @impl true
  def description, do: "Petal Pro component library for Phoenix LiveView."
  @impl true
  def requires, do: [:liveview]
  @impl true
  def conflicts_with, do: [:daisy_ui]
  @impl true
  def available_for, do: :phoenix_liveview
  @impl true
  def coming_soon?, do: false

  @impl true
  def igniter_commands(_context) do
    [
      %{type: :shell, command: "mix igniter.install petal_components --yes"}
    ]
  end

  @impl true
  def template_files(_context), do: []
end
