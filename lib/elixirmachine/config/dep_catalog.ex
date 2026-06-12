defmodule Elixirmachine.Config.DepCatalog do
  @moduledoc false

  alias Elixirmachine.Config.SectionVisibility

  @section_ids %{
    "ecto_postgres" => :database,
    "ecto_ets" => :database,
    "ash" => :database,
    "finch" => :api,
    "daisy_ui" => :liveview_frontend,
    "petal_ui" => :liveview_frontend,
    "rabbitmq" => :messaging,
    "ms_ad_ueberauth" => :auth,
    "ms_ad_elixir_auth" => :auth,
    "oban" => :jobs,
    "ash_oban" => :jobs,
    "elasticsearch" => :search,
    "solr" => :search,
    "ash_ai" => :ai,
    "langchain" => :ai,
    "sagents" => :ai,
    "credo" => :code_quality,
    "sobelow" => :code_quality,
    "excoveralls" => :code_quality,
    "mix_audit" => :code_quality,
    "styler" => :code_quality,
    "dialyxir" => :code_quality,
    "tidewave" => :dev_tools,
    "sourceror" => :dev_tools
  }

  @wizard_managed ~w(ecto_postgres ecto_ets finch)

  def wizard_managed_ids, do: @wizard_managed

  def section_for(id) when is_binary(id), do: Map.get(@section_ids, id)
  def section_for(id) when is_atom(id), do: section_for(Atom.to_string(id))

  def locked_packages(:phoenix_api), do: ["ecto_postgres"]
  def locked_packages(:phoenix_liveview), do: ["ecto_postgres"]
  def locked_packages(:standalone_otp), do: []
  def locked_packages(_), do: []

  def implicit_deps(:standalone_otp, %{"storage_backend" => "none"}), do: ["elixir"]
  def implicit_deps(:standalone_otp, %{"storage_backend" => "ets"}), do: ["elixir", "ecto_ets"]
  def implicit_deps(:standalone_otp, %{"include_database" => "false"}), do: ["elixir"]

  def implicit_deps(:standalone_otp, _config) do
    ["elixir", "ecto_sql", "postgrex"]
  end

  def implicit_deps(:phoenix_api, _config) do
    [
      "elixir",
      "ecto_sql",
      "postgrex",
      "phoenix",
      "phoenix_ecto",
      "bandit",
      "jason",
      "req"
    ]
  end

  def implicit_deps(:phoenix_liveview, _config) do
    [
      "elixir",
      "ecto_sql",
      "postgrex",
      "phoenix",
      "phoenix_live_view",
      "liveview",
      "tailwind",
      "esbuild",
      "heroicons",
      "bandit",
      "jason",
      "req"
    ]
  end

  def core_badges(project_type, configuration) do
    implicit_deps(
      project_type,
      SectionVisibility.normalize_configuration(configuration, project_type)
    )
  end

  def api_implicit_badges do
    ["req", "jason"]
  end

  def database_implicit_badges, do: []

  def liveview_implicit_badges do
    ["phoenix_live_view", "tailwind", "esbuild", "heroicons"]
  end

  def configuration_schema do
    %{
      "storage_backend" => %{
        type: "string",
        default: "none",
        options: ["none", "postgres", "ets"]
      },
      "include_database" => %{type: "boolean", default: "false"},
      "include_api" => %{type: "boolean", default: "false"},
      "http_client" => %{type: "string", default: "req", options: ["none", "req", "finch"]},
      "database_type" => %{type: "string", default: "postgres", options: ["postgres"]}
    }
  end
end
