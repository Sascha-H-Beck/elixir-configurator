defmodule Elixirmachine.Mcp.Tools.CreateGeneration do
  @moduledoc false

  use Anubis.Server.Component, type: :tool

  alias Anubis.Server.Response
  alias Elixirmachine.Generations

  schema do
    field :project_name, :string, required: true
    field :project_type, :string, required: true
    field :target_os, :string, required: true
    field :output_path, :string, required: true
    field :features, {:array, :string}, default: []
    field :configuration, :map, default: %{}
  end

  @impl true
  def execute(params, frame) do
    attrs = %{
      "project_name" => params.project_name,
      "project_type" => params.project_type,
      "target_os" => params.target_os,
      "output_path" => params.output_path,
      "features" => params[:features] || [],
      "configuration" => params[:configuration] || %{}
    }

    case Generations.create(attrs) do
      {:ok, generation, api_key} ->
        payload =
          Jason.encode!(%{
            generation_id: generation.id,
            api_key: api_key,
            script_filename: generation.script_filename,
            status: generation.status
          })

        {:reply, Response.text(Response.tool(), payload), frame}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:reply,
         Response.text(Response.tool(), "validation error: #{format_changeset(changeset)}"),
         frame}

      {:error, message} when is_binary(message) ->
        {:reply, Response.text(Response.tool(), "error: #{message}"), frame}
    end
  end

  defp format_changeset(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> inspect()
  end
end
