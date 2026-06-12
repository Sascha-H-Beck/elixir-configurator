defmodule Elixirmachine.Mcp.Server do
  @moduledoc false

  use Anubis.Server,
    name: "elixirmachine",
    version: "0.1.0",
    capabilities: [:tools]

  component(Elixirmachine.Mcp.Tools.ListFeatures)
  component(Elixirmachine.Mcp.Tools.CreateGeneration)
  component(Elixirmachine.Mcp.Tools.GetScript)
  component(Elixirmachine.Mcp.Tools.GetStatus)
end
