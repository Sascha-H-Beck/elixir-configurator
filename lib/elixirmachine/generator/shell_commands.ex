defmodule Elixirmachine.Generator.ShellCommands do
  @moduledoc false

  def install_package(package, opts \\ []) do
    only = Keyword.get(opts, :only, [])

    only_flag =
      case only do
        [] -> ""
        list -> " --only #{Enum.join(list, ",")}"
      end

    "mix igniter.install #{package} --yes#{only_flag}"
  end

  def guard_missing_file(path, command, :macos) do
    "test -f #{path} || #{command}"
  end

  def guard_missing_file(path, command, :windows) do
    "if not exist #{path} (#{command})"
  end
end
