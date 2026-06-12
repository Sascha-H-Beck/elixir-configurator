defmodule Elixirmachine.Generator.TemplateRenderer do
  @moduledoc false

  alias Elixirmachine.Generator.Planner.Context

  def render(template_path, %Context{} = context) do
    full_path = Path.join([:code.priv_dir(:elixirmachine), "templates", template_path])

    with {:ok, template} <- File.read(full_path) do
      rendered =
        EEx.eval_string(template,
          assigns: [
            project_name: context.project_name,
            features: context.features,
            project_type: context.project_type
          ]
        )

      {:ok, rendered}
    end
  end
end
