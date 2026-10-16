defmodule ElixirmachineWeb.Router do
  use ElixirmachineWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ElixirmachineWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :mcp_api do
    plug :accepts, ["json"]
    plug ElixirmachineWeb.Plugs.McpContext
    plug ElixirmachineWeb.Plugs.RateLimit, scale: 60_000, limit: 60, key_prefix: "mcp"
  end

  scope "/", ElixirmachineWeb do
    pipe_through :browser

    live "/", ConfiguratorLive, :index
    get "/generations/:id/script", GenerationController, :download
  end

  scope "/mcp" do
    pipe_through :mcp_api

    forward "/", Anubis.Server.Transport.StreamableHTTP.Plug, server: Elixirmachine.Mcp.Server
  end

  if Application.compile_env(:elixirmachine, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ElixirmachineWeb.Telemetry
    end
  end
end
