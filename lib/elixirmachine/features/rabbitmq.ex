defmodule Elixirmachine.Features.Rabbitmq do
  @moduledoc false
  @behaviour Elixirmachine.Features.Behaviour

  alias Elixirmachine.Generator.ShellCommands

  @impl true
  def id, do: :rabbitmq
  @impl true
  def label, do: "RabbitMQ"
  @impl true
  def description, do: "AMQP messaging via RabbitMQ."
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
    [%{type: :shell, command: ShellCommands.install_package("amqp")}]
  end

  @impl true
  def template_files(_context), do: []
end
