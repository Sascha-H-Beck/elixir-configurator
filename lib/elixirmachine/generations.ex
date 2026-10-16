defmodule Elixirmachine.Generations do
  @moduledoc false

  import Ecto.Query, warn: false
  alias Elixirmachine.Features.Catalog
  alias Elixirmachine.Generations.Generation
  alias Elixirmachine.Generator.ScriptBuilder
  alias Elixirmachine.Repo

  def get!(id), do: Repo.get!(Generation, id)
  def get(id), do: Repo.get(Generation, id)

  def create(attrs) do
    case Catalog.normalize_config(attrs) do
      {:error, message} when is_binary(message) ->
        {:error, message}

      {:ok, normalized} ->
        do_create(normalized)
    end
  end

  defp do_create(normalized) do
    api_key = generate_api_key()
    api_key_hash = hash_api_key(api_key)

    with {:ok, generation} <- insert_pending(normalized, api_key_hash) do
      complete_generation(generation, api_key)
    end
  end

  defp insert_pending(normalized, api_key_hash) do
    %Generation{}
    |> Generation.changeset(
      Map.merge(normalized, %{
        api_key_hash: api_key_hash,
        status: :pending
      })
    )
    |> Repo.insert()
  end

  defp complete_generation(generation, api_key) do
    case build_script(generation) do
      {:ok, script_attrs} -> persist_ready(generation, script_attrs, api_key)
      {:error, message} -> persist_failed(generation, message)
    end
  end

  defp persist_ready(generation, script_attrs, api_key) do
    case Repo.update(Generation.changeset(generation, Map.merge(script_attrs, %{status: :ready}))) do
      {:ok, updated} -> {:ok, updated, api_key}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp persist_failed(generation, message) do
    generation
    |> Generation.changeset(%{status: :failed, error_message: message})
    |> Repo.update()

    {:error, message}
  end

  def preview(attrs) do
    with {:ok, normalized} <- Catalog.normalize_config(attrs) do
      generation = struct(Generation, normalized)
      ScriptBuilder.build(generation)
    end
  end

  def verify_api_key(generation_id, api_key) when is_binary(api_key) and api_key != "" do
    with %Generation{} = generation <- get(generation_id),
         true <- secure_compare(hash_api_key(api_key), generation.api_key_hash) do
      {:ok, generation}
    else
      _ -> :error
    end
  end

  def verify_api_key(_, _), do: :error

  def mark_downloaded(%Generation{} = generation) do
    generation
    |> Generation.changeset(%{status: :downloaded})
    |> Repo.update()
  end

  defp build_script(generation) do
    case ScriptBuilder.build(generation) do
      {:ok, content, filename} ->
        {:ok, %{script_content: content, script_filename: filename}}

      {:error, message} ->
        {:error, message}
    end
  end

  defp generate_api_key do
    32 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)
  end

  defp hash_api_key(api_key) do
    :sha256 |> :crypto.hash(api_key) |> Base.encode16(case: :lower)
  end

  defp secure_compare(left, right) when is_binary(left) and is_binary(right) do
    byte_size(left) == byte_size(right) and Plug.Crypto.secure_compare(left, right)
  end
end
