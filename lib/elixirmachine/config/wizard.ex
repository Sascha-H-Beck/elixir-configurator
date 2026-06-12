defmodule Elixirmachine.Config.Wizard do
  @moduledoc false

  alias Elixirmachine.Config.SectionVisibility

  @addon_sections [:auth, :messaging, :jobs, :search, :ai, :code_quality, :dev_tools]

  @steps [
    :project,
    :storage,
    :http,
    :frontend,
    :addons,
    :review
  ]

  def steps(:standalone_otp), do: [:project, :storage, :http, :addons, :review]
  def steps(:phoenix_api), do: [:project, :storage, :http, :addons, :review]
  def steps(:phoenix_liveview), do: [:project, :storage, :http, :frontend, :addons, :review]
  def steps(_), do: [:project, :storage, :http, :addons, :review]

  def step_label(:project), do: "Project"
  def step_label(:storage), do: "Storage"
  def step_label(:http), do: "HTTP / API"
  def step_label(:frontend), do: "Frontend"
  def step_label(:addons), do: "Add-ons"
  def step_label(:review), do: "Review"

  def addon_sections, do: @addon_sections

  def addon_section_label(:auth), do: "Authentication"
  def addon_section_label(:messaging), do: "Messaging"
  def addon_section_label(:jobs), do: "Background jobs"
  def addon_section_label(:search), do: "Search"
  def addon_section_label(:ai), do: "AI & agents"
  def addon_section_label(:code_quality), do: "Code quality"
  def addon_section_label(:dev_tools), do: "Dev tools"

  def step_index(steps, step), do: Enum.find_index(steps, &(&1 == step))

  def next_step(steps, step) do
    case step_index(steps, step) do
      nil -> step
      idx -> Enum.at(steps, idx + 1, step)
    end
  end

  def prev_step(steps, step) do
    case step_index(steps, step) do
      nil -> step
      0 -> step
      idx -> Enum.at(steps, idx - 1, step)
    end
  end

  def validate_step(:project, params) do
    name = String.trim(Map.get(params, "project_name", ""))
    path = String.trim(Map.get(params, "output_path", ""))

    cond do
      name == "" ->
        {:error, %{project_name: "Project name is required"}}

      not Regex.match?(~r/^[a-z][a-z0-9_]*$/, name) ->
        {:error,
         %{
           project_name:
             "Must start with a letter and contain only lowercase letters, numbers, and underscores"
         }}

      path == "" ->
        {:error, %{output_path: "Output path is required"}}

      true ->
        :ok
    end
  end

  def validate_step(:storage, %{"project_type" => "standalone_otp"} = params) do
    backend = params |> config() |> Map.get("storage_backend", "")

    if backend in ["none", "postgres", "ets"] do
      :ok
    else
      {:error, %{storage_backend: "Choose a storage option"}}
    end
  end

  def validate_step(:storage, _params), do: :ok

  def validate_step(:http, %{"project_type" => "phoenix_api"} = _params), do: :ok

  def validate_step(:http, params) do
    include_api = params |> config() |> Map.get("include_api", "")

    if include_api in ["true", "false"] do
      :ok
    else
      {:error, %{include_api: "Choose whether to include HTTP/API endpoints"}}
    end
  end

  def validate_step(:frontend, _params), do: :ok
  def validate_step(:addons, _params), do: :ok
  def validate_step(:review, _params), do: :ok
  def validate_step(_, _params), do: :ok

  def metadata_for_mcp do
    Enum.map(@steps, fn step ->
      %{id: Atom.to_string(step), label: step_label(step)}
    end)
  end

  defp config(params) do
    params
    |> Map.get("configuration", %{})
    |> SectionVisibility.normalize_configuration(
      Map.get(params, "project_type", "phoenix_liveview")
    )
  end
end
