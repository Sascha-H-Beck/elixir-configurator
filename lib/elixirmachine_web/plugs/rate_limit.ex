defmodule ElixirmachineWeb.Plugs.RateLimit do
  @moduledoc false

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, opts) do
    scale = Keyword.get(opts, :scale, 60_000)
    limit = Keyword.get(opts, :limit, 60)
    key_prefix = Keyword.get(opts, :key_prefix, "rate")

    key = "#{key_prefix}:#{remote_ip(conn)}"

    case Hammer.check_rate(key, scale, limit) do
      {:allow, _count} ->
        conn

      {:deny, _limit} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(429, Jason.encode!(%{error: "rate limit exceeded"}))
        |> halt()
    end
  end

  defp remote_ip(conn) do
    conn.remote_ip
    |> :inet.ntoa()
    |> to_string()
  end
end
