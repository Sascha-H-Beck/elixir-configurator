defmodule ElixirmachineWeb.Plugs.McpContext do
  @moduledoc false

  import Plug.Conn
  alias Elixirmachine.Mcp.Auth

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> get_req_header("authorization")
    |> parse_bearer()
    |> Auth.store_bearer()

    conn
  end

  defp parse_bearer(["Bearer " <> token]), do: token
  defp parse_bearer(_), do: nil
end
