defmodule Elixirmachine.Config.WizardTest do
  use ExUnit.Case, async: true

  alias Elixirmachine.Config.Wizard

  test "standalone wizard steps" do
    assert Wizard.steps(:standalone_otp) == [:project, :storage, :http, :addons, :review]
  end

  test "liveview wizard includes frontend step" do
    assert :frontend in Wizard.steps(:phoenix_liveview)
    refute :frontend in Wizard.steps(:phoenix_api)
  end

  test "validate project step requires name and path" do
    assert {:error, errors} =
             Wizard.validate_step(:project, %{"project_name" => "", "output_path" => ""})

    assert errors.project_name
  end

  test "validate storage requires backend on standalone" do
    assert {:error, _} =
             Wizard.validate_step(:storage, %{
               "project_type" => "standalone_otp",
               "configuration" => %{"storage_backend" => ""}
             })

    assert :ok =
             Wizard.validate_step(:storage, %{
               "project_type" => "standalone_otp",
               "configuration" => %{"storage_backend" => "postgres"}
             })
  end
end
