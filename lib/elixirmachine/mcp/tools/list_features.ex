defmodule Elixirmachine.Mcp.Tools.ListFeatures do
  @moduledoc false

  use Anubis.Server.Component, type: :tool

  alias Anubis.Server.Response
  alias Elixirmachine.Config.{DepCatalog, SectionVisibility, Wizard}
  alias Elixirmachine.Features.Catalog

  schema do
  end

  @impl true
  def execute(_params, frame) do
    payload =
      Jason.encode!(%{
        features: Catalog.list(),
        sections: Enum.map(SectionVisibility.sections(), &section_payload/1),
        configuration_schema: DepCatalog.configuration_schema(),
        wizard_steps: Wizard.metadata_for_mcp()
      })

    {:reply, Response.text(Response.tool(), payload), frame}
  end

  defp section_payload(section) do
    %{
      id: Atom.to_string(section),
      label: SectionVisibility.section_label(section),
      open_by_default: SectionVisibility.section_open_by_default?(section)
    }
  end
end
