defmodule ElixirmachineWeb.GenerationController do
  use ElixirmachineWeb, :controller

  alias Elixirmachine.Generations

  def download(conn, %{"id" => id}) do
    api_key = conn.params["api_key"] || bearer(conn)

    case Generations.verify_api_key(id, api_key || "") do
      {:ok, generation} ->
        Generations.mark_downloaded(generation)

        conn
        |> put_resp_content_type(content_type(generation))
        |> put_resp_header(
          "content-disposition",
          "attachment; filename=\"#{generation.script_filename}\""
        )
        |> send_resp(200, generation.script_content || "")

      :error ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "invalid api_key"})
    end
  end

  defp bearer(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> token
      _ -> nil
    end
  end

  defp content_type(%{script_filename: name}) when is_binary(name) do
    if String.ends_with?(name, ".bat"), do: "application/x-bat", else: "application/x-sh"
  end

  defp content_type(_), do: "text/plain"
end
