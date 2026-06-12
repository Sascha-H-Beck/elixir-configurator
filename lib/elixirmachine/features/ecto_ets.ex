defmodule Elixirmachine.Features.EctoEts do
  @moduledoc false
  @behaviour Elixirmachine.Features.Behaviour

  @impl true
  def id, do: :ecto_ets

  @impl true
  def label, do: "Ecto + ETS (in-memory)"

  @impl true
  def description, do: "Ecto with the ETS adapter for in-memory persistence during development."

  @impl true
  def requires, do: []

  @impl true
  def conflicts_with, do: [:ecto_postgres]

  @impl true
  def available_for, do: :standalone_otp

  @impl true
  def coming_soon?, do: false

  @impl true
  def igniter_commands(%{project_type: :standalone_otp}) do
    [%{type: :shell, command: "mix igniter.install ecto_ets --yes"}]
  end

  @impl true
  def igniter_commands(_context), do: []

  @impl true
  def template_files(_context), do: []
end
