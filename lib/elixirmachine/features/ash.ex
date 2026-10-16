defmodule Elixirmachine.Features.Ash do
  @moduledoc false
  @behaviour Elixirmachine.Features.Behaviour

  @impl true
  def id, do: :ash
  @impl true
  def label, do: "Ash Framework"
  @impl true
  def description, do: "Ash domain layer with AshPostgres data layer."
  @impl true
  def requires, do: [:ecto_postgres]
  @impl true
  def conflicts_with, do: []
  @impl true
  def available_for, do: :both
  @impl true
  def coming_soon?, do: false

  @impl true
  def igniter_commands(%{project_type: :standalone_otp}) do
    [
      %{type: :shell, command: "mix igniter.install ash ash_postgres --yes"}
    ]
  end

  @impl true
  def igniter_commands(%{project_type: :phoenix_api}) do
    [
      %{type: :shell, command: "mix igniter.install ash ash_postgres ash_phoenix --yes"}
    ]
  end

  @impl true
  def igniter_commands(%{project_type: :phoenix_liveview}) do
    [
      %{type: :shell, command: "mix igniter.install ash ash_postgres ash_phoenix --yes"}
    ]
  end

  @impl true
  def template_files(_context), do: []
end
