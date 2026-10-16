defmodule Elixirmachine.Features.PhoenixApi do
  @moduledoc false
  @behaviour Elixirmachine.Features.Behaviour

  @impl true
  def id, do: :phoenix_api
  @impl true
  def label, do: "Phoenix API"
  @impl true
  def description, do: "Phoenix JSON API without LiveView/HTML."
  @impl true
  def requires, do: [:ecto_postgres]
  @impl true
  def conflicts_with, do: []
  @impl true
  def available_for, do: :phoenix_api
  @impl true
  def coming_soon?, do: false

  def scaffold?, do: true

  @impl true
  def igniter_commands(%{project_name: name}) do
    [
      %{
        type: :shell,
        command:
          "mix igniter.new #{name} --install postgres --with phx.new --with-args=\"--no-html --no-mailer\""
      }
    ]
  end

  @impl true
  def template_files(_context) do
    [{"docker-compose.yml", "docker/docker-compose.yml.eex"}]
  end
end
