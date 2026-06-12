defmodule ElixirmachineWeb.GenerationControllerTest do
  use ElixirmachineWeb.ConnCase, async: true

  alias Elixirmachine.Generations

  test "download requires valid api key", %{conn: conn} do
    {:ok, generation, api_key} =
      Generations.create(%{
        "project_name" => "demo_app",
        "project_type" => "standalone_otp",
        "target_os" => "macos",
        "output_path" => "/Users/dev/demo_app",
        "features" => []
      })

    conn = get(conn, ~p"/generations/#{generation.id}/script?api_key=#{api_key}")
    assert response(conn, 200) =~ "mix igniter.new"

    conn =
      build_conn()
      |> get(~p"/generations/#{generation.id}/script?api_key=invalid")

    assert response(conn, 401)
  end
end
