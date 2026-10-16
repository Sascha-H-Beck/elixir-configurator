defmodule Elixirmachine.Features.EctoPostgres do
  @moduledoc false
  @behaviour Elixirmachine.Features.Behaviour

  @impl true
  def id, do: :ecto_postgres

  @impl true
  def label, do: "Ecto + PostgreSQL"

  @impl true
  def description, do: "Ecto SQL with Postgrex driver, Docker Compose, and database integration."

  @impl true
  def requires, do: []

  @impl true
  def conflicts_with, do: [:ecto_ets]

  @impl true
  def available_for, do: :both

  @impl true
  def coming_soon?, do: false

  @impl true
  def igniter_commands(%{project_type: :standalone_otp}), do: []

  @impl true
  def igniter_commands(%{project_type: :phoenix_api}), do: []

  @impl true
  def igniter_commands(%{project_type: :phoenix_liveview}), do: []

  @impl true
  def igniter_commands(_context), do: []

  @impl true
  def template_files(%{project_type: :standalone_otp}) do
    [{"docker-compose.yml", "docker/docker-compose.yml.eex"}]
  end

  def template_files(_context), do: []
end
