defmodule Elixirmachine.Features.CodeQuality.Sobelow do
  @moduledoc false
  @behaviour Elixirmachine.Features.Behaviour

  alias Elixirmachine.Generator.ShellCommands

  @impl true
  def id, do: :sobelow
  @impl true
  def label, do: "Sobelow"
  @impl true
  def description, do: "Security scanner — generates .sobelow-conf when the script runs."
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
      %{type: :shell, command: ShellCommands.install_package("sobelow", only: ["dev", "test"])},
      %{
        type: :shell,
        command:
          ShellCommands.guard_missing_file(
            ".sobelow-conf",
            "mix sobelow --save-config --exit Medium",
            os
          )
      }
    ]
  end

  @impl true
  def template_files(_context), do: []
end
