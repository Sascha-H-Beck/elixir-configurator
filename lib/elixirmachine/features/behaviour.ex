defmodule Elixirmachine.Features.Behaviour do
  @moduledoc false

  @type project_type :: :standalone_otp | :phoenix_api | :phoenix_liveview
  @type availability :: :standalone_otp | :phoenix_api | :phoenix_liveview | :both

  @callback id() :: atom()
  @callback label() :: String.t()
  @callback description() :: String.t()
  @callback requires() :: [atom()]
  @callback conflicts_with() :: [atom()]
  @callback available_for() :: availability()
  @callback coming_soon?() :: boolean()
  @callback igniter_commands(Elixirmachine.Generator.Planner.Context.t()) :: [map()]
  @callback template_files(Elixirmachine.Generator.Planner.Context.t()) :: [
              {String.t(), String.t()}
            ]

  @optional_callbacks []

  def scaffold?(module) do
    function_exported?(module, :scaffold?, 0) and module.scaffold?()
  end

  def code_quality?(module) do
    function_exported?(module, :code_quality?, 0) and module.code_quality?()
  end
end
