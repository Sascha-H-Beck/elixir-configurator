defmodule Elixirmachine.Features.CatalogTest do
  use ExUnit.Case, async: true

  alias Elixirmachine.Features.{Ash, Catalog, CodeQuality.Credo, EctoPostgres}

  test "lists selectable features without coming soon stubs" do
    ids = Catalog.selectable() |> Enum.map(& &1.id)
    assert "ash" in ids
    assert "ecto_postgres" in ids
    assert "ecto_ets" in ids
    assert "finch" in ids
    assert "rabbitmq" in ids
    assert "credo" in ids
    refute "oban" in ids
  end

  test "packages_for_section returns ash and ecto_postgres in database section" do
    packages = Catalog.packages_for_section(:database, :phoenix_liveview, %{})
    ids = Enum.map(packages, & &1.id)
    assert "ash" in ids
    assert "ecto_postgres" in ids
  end

  test "phoenix database packages mark ecto_postgres as locked" do
    packages = Catalog.packages_for_section(:database, :phoenix_liveview, %{})
    ecto = Enum.find(packages, &(&1.id == "ecto_postgres"))
    assert ecto.locked
    refute ecto.selectable
  end

  test "resolve_selection expands ash requires ecto_postgres" do
    assert {:ok, result} =
             Catalog.resolve_selection(:standalone_otp, ["ash"], :skip_acceptance, %{
               "storage_backend" => "postgres",
               "include_database" => "true"
             })

    assert "ecto_postgres" in result.resolved
    assert "ash" in result.resolved
  end

  test "resolve_selection locks ecto_postgres on phoenix liveview" do
    assert {:ok, result} =
             Catalog.resolve_selection(:phoenix_liveview, ["daisy_ui"], :skip_acceptance)

    assert "ecto_postgres" in result.resolved
    assert "ecto_postgres" in result.locked
    assert result.required_additions == []
    assert "liveview" in result.resolved
    assert "daisy_ui" in result.resolved
  end

  test "adjust_selected_for_acceptance removes parent when required package unchecked" do
    selected = ["daisy_ui"]
    required = ["liveview"]
    accepted = []

    adjusted = Catalog.adjust_selected_for_acceptance(selected, accepted, required)
    assert adjusted == []
  end

  test "normalize_config stores user-selected features" do
    assert {:ok, %{features: features}} =
             Catalog.normalize_config(%{
               "project_name" => "my_app",
               "project_type" => "phoenix_liveview",
               "target_os" => "macos",
               "output_path" => "/Users/dev/my_app",
               "features" => ["daisy_ui"]
             })

    assert features == ["daisy_ui"]
  end

  test "normalize_config stores daisy_ui from features checkbox" do
    assert {:ok, %{features: features}} =
             Catalog.normalize_config(%{
               "project_name" => "my_app",
               "project_type" => "phoenix_liveview",
               "target_os" => "macos",
               "output_path" => "/Users/dev/my_app",
               "features" => ["petal_ui"]
             })

    assert features == ["petal_ui"]
  end

  test "rejects daisy_ui on standalone project type" do
    assert {:error, _message} =
             Catalog.normalize_config(%{
               "project_name" => "my_app",
               "project_type" => "standalone_otp",
               "target_os" => "macos",
               "output_path" => "/tmp/x",
               "features" => ["daisy_ui"]
             })
  end

  test "rejects conflicting daisy_ui and petal_ui" do
    assert {:error, message} =
             Catalog.normalize_config(%{
               "project_name" => "my_app",
               "project_type" => "phoenix_liveview",
               "target_os" => "macos",
               "output_path" => "/tmp/x",
               "features" => ["daisy_ui", "petal_ui"]
             })

    assert message =~ "conflicting"
  end

  test "ash igniter commands differ by project type" do
    standalone = Ash.igniter_commands(%{project_type: :standalone_otp})
    phoenix = Ash.igniter_commands(%{project_type: :phoenix_liveview})

    assert hd(standalone).command =~ "ash_postgres"
    refute hd(standalone).command =~ "ash_phoenix"
    assert hd(phoenix).command =~ "ash_phoenix"
  end

  test "credo igniter commands install and generate config" do
    commands = Credo.igniter_commands(%{target_os: :macos}) |> Enum.map(& &1.command)

    assert Enum.any?(commands, &String.contains?(&1, "mix igniter.install credo"))
    assert Enum.any?(commands, &String.contains?(&1, "credo.gen.config"))
  end

  test "ecto_postgres template files on standalone" do
    templates = EctoPostgres.template_files(%{project_type: :standalone_otp})
    assert {"docker-compose.yml", "docker/docker-compose.yml.eex"} in templates
  end
end
