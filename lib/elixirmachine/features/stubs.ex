defmodule Elixirmachine.Features.Stub do
  @moduledoc false

  defmacro __using__(opts) do
    id = Keyword.fetch!(opts, :id)
    label = Keyword.fetch!(opts, :label)
    description = Keyword.fetch!(opts, :description)
    available_for = Keyword.get(opts, :available_for, :both)

    quote do
      @behaviour Elixirmachine.Features.Behaviour

      @impl true
      def id, do: unquote(id)
      @impl true
      def label, do: unquote(label)
      @impl true
      def description, do: unquote(description)
      @impl true
      def requires, do: []
      @impl true
      def conflicts_with, do: []
      @impl true
      def available_for, do: unquote(available_for)
      @impl true
      def coming_soon?, do: true
      @impl true
      def igniter_commands(_context), do: []
      @impl true
      def template_files(_context), do: []
    end
  end
end

defmodule Elixirmachine.Features.Elasticsearch do
  @moduledoc false
  use Elixirmachine.Features.Stub,
    id: :elasticsearch,
    label: "Elasticsearch",
    description: "Full-text search with Elasticsearch."
end

defmodule Elixirmachine.Features.Solr do
  @moduledoc false
  use Elixirmachine.Features.Stub,
    id: :solr,
    label: "Apache Solr",
    description: "Search platform integration with Solr."
end

defmodule Elixirmachine.Features.MsAdUeberauth do
  @moduledoc false
  use Elixirmachine.Features.Stub,
    id: :ms_ad_ueberauth,
    label: "Microsoft AD (Ueberauth)",
    description: "Azure AD SSO via ueberauth and ueberauth_microsoft."
end

defmodule Elixirmachine.Features.MsAdElixirAuth do
  @moduledoc false
  use Elixirmachine.Features.Stub,
    id: :ms_ad_elixir_auth,
    label: "Microsoft AD (ElixirAuth)",
    description: "Azure AD via elixir_auth_microsoft and joken."
end

defmodule Elixirmachine.Features.Oban do
  @moduledoc false
  use Elixirmachine.Features.Stub,
    id: :oban,
    label: "Oban",
    description: "Background jobs with Oban and Oban Web."
end

defmodule Elixirmachine.Features.AshOban do
  @moduledoc false
  use Elixirmachine.Features.Stub,
    id: :ash_oban,
    label: "AshOban",
    description: "Ash integration for Oban background jobs."
end

defmodule Elixirmachine.Features.AshAi do
  @moduledoc false
  use Elixirmachine.Features.Stub,
    id: :ash_ai,
    label: "Ash AI",
    description: "Ash AI extensions for LLM-powered resources.",
    available_for: :phoenix_liveview
end

defmodule Elixirmachine.Features.Langchain do
  @moduledoc false
  use Elixirmachine.Features.Stub,
    id: :langchain,
    label: "LangChain",
    description: "LangChain Elixir bindings.",
    available_for: :phoenix_liveview
end

defmodule Elixirmachine.Features.Sagents do
  @moduledoc false
  use Elixirmachine.Features.Stub,
    id: :sagents,
    label: "Sagents",
    description: "AI agent orchestration framework.",
    available_for: :phoenix_liveview
end

defmodule Elixirmachine.Features.Styler do
  @moduledoc false
  use Elixirmachine.Features.Stub,
    id: :styler,
    label: "Styler",
    description: "Opinionated formatter and refactor tools."
end

defmodule Elixirmachine.Features.Dialyxir do
  @moduledoc false
  use Elixirmachine.Features.Stub,
    id: :dialyxir,
    label: "Dialyxir",
    description: "Dialyzer wrapper — PLT setup required."
end

defmodule Elixirmachine.Features.Tidewave do
  @moduledoc false
  use Elixirmachine.Features.Stub,
    id: :tidewave,
    label: "Tidewave",
    description: "In-editor MCP and debugging for Phoenix."
end

defmodule Elixirmachine.Features.Sourceror do
  @moduledoc false
  use Elixirmachine.Features.Stub,
    id: :sourceror,
    label: "Sourceror",
    description: "AST utilities for codemods and macros."
end
