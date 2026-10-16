defmodule Elixirmachine.Features.CodeQuality.MixAudit do
  @moduledoc false
  @behaviour Elixirmachine.Features.Behaviour

  alias Elixirmachine.Generator.ShellCommands

  @impl true
  def id, do: :mix_audit
  @impl true
  def label, do: "Mix Audit"
  @impl true
  def description, do: "Hex advisory checks for known vulnerabilities."
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
    [%{type: :shell, command: ShellCommands.install_package("mix_audit", only: ["dev", "test"])}]
  end

  @impl true
  def template_files(_context), do: []
end
