defmodule Elixirmachine.Config.SectionVisibility do
  @moduledoc false

  @sections [
    :core,
    :database,
    :api,
    :liveview_frontend,
    :auth,
    :messaging,
    :jobs,
    :search,
    :ai,
    :code_quality,
    :dev_tools
  ]

  def sections, do: @sections

  def section_label(:core), do: "Core"
  def section_label(:database), do: "Database"
  def section_label(:api), do: "API"
  def section_label(:liveview_frontend), do: "LiveView & Frontend"
  def section_label(:auth), do: "Authentication"
  def section_label(:messaging), do: "Messaging"
  def section_label(:jobs), do: "Background jobs"
  def section_label(:search), do: "Search"
  def section_label(:ai), do: "AI & agents"
  def section_label(:code_quality), do: "Code quality"
  def section_label(:dev_tools), do: "Dev tools"

  def section_open_by_default?(:code_quality), do: true
  def section_open_by_default?(_), do: false

  def visible_sections(project_type, configuration) when is_map(configuration) do
    configuration = normalize_configuration(configuration, project_type)

    @sections
    |> Enum.filter(&visible?(&1, project_type, configuration))
  end

  defp visible?(:core, _, _), do: true

  defp visible?(:database, :standalone_otp, config) do
    config["storage_backend"] in ["postgres", "ets"] or config["include_database"] == "true"
  end

  defp visible?(:database, :phoenix_api, _), do: true
  defp visible?(:database, :phoenix_liveview, _), do: true
  defp visible?(:database, _, _), do: false

  defp visible?(:api, :standalone_otp, config), do: config["include_api"] == "true"
  defp visible?(:api, :phoenix_api, _), do: true
  defp visible?(:api, :phoenix_liveview, config), do: config["include_api"] == "true"
  defp visible?(:api, _, _), do: false

  defp visible?(:liveview_frontend, :phoenix_liveview, _), do: true
  defp visible?(:liveview_frontend, _, _), do: false

  defp visible?(:auth, _, _), do: true
  defp visible?(:messaging, _, _), do: true
  defp visible?(:jobs, _, _), do: true
  defp visible?(:search, _, _), do: true

  defp visible?(:ai, :phoenix_liveview, _), do: true
  defp visible?(:ai, _, _), do: false

  defp visible?(:code_quality, _, _), do: true
  defp visible?(:dev_tools, _, _), do: true

  def normalize_configuration(config, project_type \\ :phoenix_liveview) when is_map(config) do
    config =
      Map.new(config, fn
        {k, v} when is_atom(k) -> {Atom.to_string(k), to_string(v)}
        {k, v} -> {k, to_string(v)}
      end)

    defaults = default_configuration(project_type)

    Map.merge(defaults, config)
  end

  def default_configuration(:standalone_otp) do
    default_configuration("standalone_otp")
  end

  def default_configuration(project_type) when is_atom(project_type) do
    default_configuration(Atom.to_string(project_type))
  end

  def default_configuration("standalone_otp") do
    %{
      "storage_backend" => "none",
      "include_database" => "false",
      "include_api" => "false",
      "http_client" => "req",
      "database_type" => "postgres"
    }
  end

  def default_configuration("phoenix_api") do
    %{
      "storage_backend" => "postgres",
      "include_database" => "true",
      "include_api" => "true",
      "http_client" => "req",
      "database_type" => "postgres"
    }
  end

  def default_configuration(_phoenix_liveview) do
    %{
      "storage_backend" => "postgres",
      "include_database" => "true",
      "include_api" => "false",
      "http_client" => "req",
      "database_type" => "postgres"
    }
  end

  def defaults_for_project_type(project_type) do
    default_configuration(project_type)
  end
end
