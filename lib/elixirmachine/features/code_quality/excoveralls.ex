defmodule Elixirmachine.Features.CodeQuality.Excoveralls do
  @moduledoc false
  @behaviour Elixirmachine.Features.Behaviour

  alias Elixirmachine.Generator.ShellCommands

  @impl true
  def id, do: :excoveralls
  @impl true
  def label, do: "ExCoveralls"
  @impl true
  def description, do: "Test coverage reporting — writes coveralls.json."
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
  def igniter_commands(_context) do
    [
      %{
        type: :shell,
        command: ShellCommands.install_package("excoveralls", only: ["dev", "test"])
      }
    ]
  end

  @impl true
  def template_files(_context) do
    [{"coveralls.json", "code_quality/coveralls.json.eex"}]
  end
end
