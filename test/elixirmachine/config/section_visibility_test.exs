defmodule Elixirmachine.Config.SectionVisibilityTest do
  use ExUnit.Case, async: true

  alias Elixirmachine.Config.SectionVisibility

  test "standalone with storage none hides database section" do
    sections =
      SectionVisibility.visible_sections(:standalone_otp, %{
        "storage_backend" => "none",
        "include_database" => "false"
      })

    refute :database in sections
    assert :code_quality in sections
  end

  test "standalone with postgres shows database section" do
    sections =
      SectionVisibility.visible_sections(:standalone_otp, %{
        "storage_backend" => "postgres",
        "include_database" => "true"
      })

    assert :database in sections
  end

  test "standalone with ets shows database section" do
    sections =
      SectionVisibility.visible_sections(:standalone_otp, %{
        "storage_backend" => "ets",
        "include_database" => "true"
      })

    assert :database in sections
  end

  test "phoenix api shows database and api but not liveview" do
    sections = SectionVisibility.visible_sections(:phoenix_api, %{})

    assert :database in sections
    assert :api in sections
    refute :liveview_frontend in sections
  end

  test "phoenix liveview shows liveview section and ai" do
    sections = SectionVisibility.visible_sections(:phoenix_liveview, %{})

    assert :liveview_frontend in sections
    assert :ai in sections
  end
end
