defmodule Elixirmachine.Features.Liveview do
  @moduledoc false
  @behaviour Elixirmachine.Features.Behaviour

  @impl true
  def id, do: :liveview
  @impl true
  def label, do: "Phoenix LiveView"
  @impl true
  def description, do: "Phoenix web application with LiveView."
  @impl true
  def requires, do: []
  @impl true
  def conflicts_with, do: []
  @impl true
  def available_for, do: :phoenix_liveview
  @impl true
  def coming_soon?, do: false

  def scaffold?, do: true

  @impl true
  def igniter_commands(%{project_name: name}) do
    [
      %{
        type: :shell,
        command:
          "mix igniter.new #{name} --install postgres --with phx.new --with-args=\"--no-mailer\""
      }
    ]
  end

  @impl true
  def template_files(context) do
    case context.project_type do
      :phoenix_liveview ->
        [{"Dockerfile", "docker/Dockerfile.app.eex"}]

      _ ->
        []
    end
  end
end
