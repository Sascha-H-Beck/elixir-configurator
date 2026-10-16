defmodule Elixirmachine.GenerationsTest do
  use Elixirmachine.DataCase, async: true

  alias Elixirmachine.Generations

  test "create returns api key and ready script" do
    assert {:ok, generation, api_key} =
             Generations.create(%{
               "project_name" => "demo_app",
               "project_type" => "standalone_otp",
               "target_os" => "macos",
               "output_path" => "/Users/dev/demo_app",
               "features" => []
             })

    assert is_binary(api_key)
    assert generation.status == :ready
    assert generation.script_filename == "build-demo_app.sh"
    assert Generations.verify_api_key(generation.id, api_key) == {:ok, generation}
    assert Generations.verify_api_key(generation.id, "wrong") == :error
  end
end
