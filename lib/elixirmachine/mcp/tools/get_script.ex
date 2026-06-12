defmodule Elixirmachine.Mcp.Tools.GetScript do
  @moduledoc false

  use Anubis.Server.Component, type: :tool

  alias Anubis.Server.Response
  alias Elixirmachine.Generations
  alias Elixirmachine.Mcp.Auth

  schema do
    field :generation_id, :string, required: true
    field :api_key, :string
  end

  @impl true
  def execute(params, frame) do
    tool_params = %{
      "generation_id" => params.generation_id,
      "api_key" => params[:api_key]
    }

    with :ok <- Auth.verify_for_tool("get_script", tool_params),
         {:ok, generation} <- fetch_generation(params.generation_id) do
      payload =
        Jason.encode!(%{
          filename: generation.script_filename,
          content: generation.script_content,
          content_type: content_type(generation)
        })

      {:reply, Response.text(Response.tool(), payload), frame}
    else
      {:error, message} ->
        {:reply, Response.text(Response.tool(), "error: #{message}"), frame}
    end
  end

  defp fetch_generation(id) do
    case Generations.get(id) do
      nil -> {:error, "generation not found"}
      generation -> {:ok, generation}
    end
  end

  defp content_type(%{script_filename: name}) when is_binary(name) do
    if String.ends_with?(name, ".bat"), do: "application/x-bat", else: "application/x-sh"
  end

  defp content_type(_), do: "text/plain"
end
