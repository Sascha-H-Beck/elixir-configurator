defmodule Elixirmachine.Config.Wizard.SyncTest do
  use ExUnit.Case, async: true

  alias Elixirmachine.Config.Wizard.Sync

  test "sync postgres configuration on standalone" do
    params =
      Sync.sync_all(%{
        "project_type" => "standalone_otp",
        "features" => [],
        "configuration" => %{"storage_backend" => "postgres"}
      })

    refute "ecto_postgres" in params["features"]
    assert params["configuration"]["include_database"] == "true"
    assert "ecto_postgres" in Sync.derived_feature_ids("standalone_otp", params["configuration"])
  end

  test "derived ets removes ash from user features via sync" do
    params =
      Sync.sync_all(%{
        "project_type" => "standalone_otp",
        "features" => ["ash"],
        "configuration" => %{"storage_backend" => "ets"}
      })

    refute "ash" in params["features"]
    assert "ecto_ets" in Sync.derived_feature_ids("standalone_otp", params["configuration"])
  end

  test "sync phoenix forces postgres storage" do
    params =
      Sync.sync_all(%{
        "project_type" => "phoenix_liveview",
        "features" => [],
        "configuration" => %{"storage_backend" => "none"}
      })

    assert params["configuration"]["storage_backend"] == "postgres"

    assert "ecto_postgres" in Sync.derived_feature_ids(
             "phoenix_liveview",
             params["configuration"]
           )
  end

  test "derived finch when http enabled" do
    config = %{
      "storage_backend" => "none",
      "include_api" => "true",
      "http_client" => "finch"
    }

    assert "finch" in Sync.derived_feature_ids("standalone_otp", config)
  end
end
