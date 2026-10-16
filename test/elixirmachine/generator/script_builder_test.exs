defmodule Elixirmachine.Generator.ScriptBuilderTest do
  use ExUnit.Case, async: true

  alias Elixirmachine.Generations.Generation
  alias Elixirmachine.Generator.ScriptBuilder

  test "macOS script cds to explicit output path" do
    generation = %Generation{
      project_name: "demo_app",
      project_type: :standalone_otp,
      target_os: :macos,
      output_path: "/Users/dev/demo_app",
      features: ["ash"]
    }

    assert {:ok, script, "build-demo_app.sh"} = ScriptBuilder.build(generation)
    assert String.contains?(script, "OUTPUT_PATH=\"/Users/dev/demo_app\"")
    assert String.contains?(script, "mix igniter.new demo_app")
  end

  test "Windows script uses bat cd and call mix" do
    generation = %Generation{
      project_name: "demo_app",
      project_type: :phoenix_liveview,
      target_os: :windows,
      output_path: "C:\\Projects\\demo_app",
      features: []
    }

    assert {:ok, script, "build-demo_app.bat"} = ScriptBuilder.build(generation)
    assert String.contains?(script, "cd /d \"%OUTPUT_PATH%\"")
    assert String.contains?(script, "call mix archive.install")
  end
end
