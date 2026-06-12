defmodule Elixirmachine.Features.Finch do
  @moduledoc false
  @behaviour Elixirmachine.Features.Behaviour

  @impl true
  def id, do: :finch

  @impl true
  def label, do: "Finch"

  @impl true
  def description, do: "HTTP connection pooling client built on Mint."

  @impl true
  def requires, do: []

  @impl true
  def conflicts_with, do: []

  @impl true
  def available_for, do: :both

  @impl true
  def coming_soon?, do: false

  @impl true
  def igniter_commands(_context) do
    [%{type: :shell, command: "mix igniter.install finch --yes"}]
  end

  @impl true
  def template_files(_context), do: []
end
