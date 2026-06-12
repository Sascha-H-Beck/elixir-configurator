defmodule Elixirmachine.Features.CodeQuality.Credo do
  @moduledoc false
  @behaviour Elixirmachine.Features.Behaviour

  alias Elixirmachine.Generator.ShellCommands

  @impl true
  def id, do: :credo
  @impl true
  def label, do: "Credo"
  @impl true
  def description, do: "Static analysis — generates .credo.exs when the script runs."
  @impl true
  def requires, do: []
  @impl true
  def conflicts_with, do: []
  @impl true
  def available_for, do: :both
  @impl true
  def coming_soon?, do: false

  def code_quality?, do: true

  @impl true
  def igniter_commands(%{target_os: os}) do
    [
      %{type: :shell, command: ShellCommands.install_package("credo", only: ["dev", "test"])},
      %{
        type: :shell,
        command: ShellCommands.guard_missing_file(".credo.exs", "mix credo.gen.config", os)
      }
    ]
  end

  @impl true
  def template_files(_context), do: []
end
