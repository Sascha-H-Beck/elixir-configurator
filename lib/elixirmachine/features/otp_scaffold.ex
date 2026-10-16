defmodule Elixirmachine.Features.OtpScaffold do
  @moduledoc false
  @behaviour Elixirmachine.Features.Behaviour

  @impl true
  def id, do: :otp_scaffold

  @impl true
  def label, do: "OTP scaffold"

  @impl true
  def description, do: "Internal scaffold for standalone OTP projects."

  @impl true
  def requires, do: []

  @impl true
  def conflicts_with, do: []

  @impl true
  def available_for, do: :standalone_otp

  @impl true
  def coming_soon?, do: false

  def scaffold?, do: true

  @impl true
  def igniter_commands(%{project_name: name, features: features, configuration: config}) do
    storage = Map.get(config || %{}, "storage_backend", "none")
    features = List.wrap(features)

    if "ecto_postgres" in features or storage == "postgres" do
      [%{type: :shell, command: "mix igniter.new #{name} --install postgres"}]
    else
      [%{type: :shell, command: "mix igniter.new #{name}"}]
    end
  end

  @impl true
  def igniter_commands(_context), do: []

  @impl true
  def template_files(_context), do: []
end
