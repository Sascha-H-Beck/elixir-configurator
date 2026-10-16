defmodule Elixirmachine.Generator.Planner.Context do
  @moduledoc false
  defstruct [
    :project_name,
    :project_type,
    :target_os,
    :output_path,
    :features,
    :configuration,
    :modules
  ]
end

defmodule Elixirmachine.Generator.Planner do
  @moduledoc false

  alias Elixirmachine.Features.{Behaviour, Catalog}
  alias Elixirmachine.Generations.Generation
  alias Elixirmachine.Generator.Planner.Context

  @quality_order [
    Elixirmachine.Features.CodeQuality.Credo,
    Elixirmachine.Features.CodeQuality.Sobelow,
    Elixirmachine.Features.CodeQuality.Excoveralls,
    Elixirmachine.Features.CodeQuality.MixAudit
  ]

  def plan(%Generation{} = generation) do
    modules = Catalog.enabled_modules(generation)

    context = %Context{
      project_name: generation.project_name,
      project_type: generation.project_type,
      target_os: generation.target_os,
      output_path: generation.output_path,
      features: Catalog.effective_features(generation),
      configuration: generation.configuration || %{},
      modules: modules
    }

    commands = build_commands(context, modules)
    templates = build_templates(context, modules)

    {:ok, %{context: context, commands: commands, templates: templates}}
  end

  defp build_commands(context, modules) do
    scaffold_commands = scaffold_module_commands(context, modules)
    feature_commands = feature_module_commands(context, modules)
    quality_commands = quality_module_commands(context, modules)

    (scaffold_commands ++ feature_commands ++ quality_commands)
    |> dedupe_shell_commands()
  end

  defp scaffold_module_commands(context, modules) do
    modules
    |> Enum.filter(&Behaviour.scaffold?/1)
    |> Enum.flat_map(& &1.igniter_commands(context))
  end

  defp feature_module_commands(context, modules) do
    modules
    |> Enum.reject(&(&1 |> Behaviour.scaffold?() or quality_module?(&1)))
    |> Enum.flat_map(& &1.igniter_commands(context))
  end

  defp quality_module_commands(context, modules) do
    module_set = MapSet.new(modules)

    @quality_order
    |> Enum.filter(&MapSet.member?(module_set, &1))
    |> Enum.flat_map(& &1.igniter_commands(context))
  end

  defp quality_module?(module), do: Behaviour.code_quality?(module)

  defp build_templates(context, modules) do
    modules
    |> Enum.flat_map(& &1.template_files(context))
    |> Enum.uniq_by(fn {path, _} -> path end)
  end

  defp dedupe_shell_commands(commands) do
    commands
    |> Enum.reverse()
    |> Enum.uniq_by(& &1.command)
    |> Enum.reverse()
  end
end
