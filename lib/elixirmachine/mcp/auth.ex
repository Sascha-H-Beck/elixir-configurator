defmodule Elixirmachine.Mcp.Auth do
  @moduledoc false

  alias Elixirmachine.Generations

  @public_tools ~w(list_features create_generation)

  def public_tool?(name) when name in @public_tools, do: true
  def public_tool?(_), do: false

  def verify_for_tool(tool_name, params) do
    if public_tool?(tool_name) do
      :ok
    else
      verify_generation_key(params)
    end
  end

  defp verify_generation_key(%{"generation_id" => id, "api_key" => key}) when is_binary(key) do
    case Generations.verify_api_key(id, key) do
      {:ok, _generation} -> :ok
      :error -> {:error, "invalid api_key for generation"}
    end
  end

  defp verify_generation_key(%{"generation_id" => id}) do
    case get_bearer_from_process() do
      key when is_binary(key) and key != "" ->
        verify_generation_key(%{"generation_id" => id, "api_key" => key})

      _ ->
        {:error, "api_key required in tool params or Authorization header"}
    end
  end

  defp verify_generation_key(_), do: {:error, "generation_id required"}

  def store_bearer(nil), do: :ok

  def store_bearer(token) when is_binary(token) do
    Process.put({__MODULE__, :bearer}, token)
    :ok
  end

  def get_bearer_from_process do
    Process.get({__MODULE__, :bearer})
  end
end
