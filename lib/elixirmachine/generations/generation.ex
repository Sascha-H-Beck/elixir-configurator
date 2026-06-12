defmodule Elixirmachine.Generations.Generation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "generations" do
    field :project_name, :string
    field :project_type, Ecto.Enum, values: [:standalone_otp, :phoenix_api, :phoenix_liveview]
    field :target_os, Ecto.Enum, values: [:macos, :windows]
    field :output_path, :string
    field :features, {:array, :string}, default: []
    field :configuration, :map, default: %{}
    field :api_key_hash, :string, redact: true
    field :script_content, :string
    field :script_filename, :string
    field :status, Ecto.Enum, values: [:pending, :ready, :failed, :downloaded], default: :pending
    field :error_message, :string

    timestamps(type: :utc_datetime)
  end

  @project_name_regex ~r/^[a-z][a-z0-9_]*$/

  def changeset(generation, attrs) do
    generation
    |> cast(attrs, [
      :project_name,
      :project_type,
      :target_os,
      :output_path,
      :features,
      :configuration,
      :api_key_hash,
      :script_content,
      :script_filename,
      :status,
      :error_message
    ])
    |> validate_required([:project_name, :project_type, :target_os, :output_path, :api_key_hash])
    |> validate_format(:project_name, @project_name_regex,
      message:
        "must start with a letter and contain only lowercase letters, numbers, and underscores"
    )
    |> validate_output_path()
  end

  defp validate_output_path(changeset) do
    path = get_change(changeset, :output_path) || get_field(changeset, :output_path)

    case invalid_output_path_message(changeset, path) do
      nil -> changeset
      message -> add_error(changeset, :output_path, message)
    end
  end

  defp invalid_output_path_message(_changeset, nil), do: nil

  defp invalid_output_path_message(changeset, path) do
    invalid_output_path_traversal(path) || invalid_output_path_for_os(changeset, path)
  end

  defp invalid_output_path_traversal(path) do
    if String.contains?(path, ".."), do: "must not contain .."
  end

  defp invalid_output_path_for_os(changeset, path) do
    case get_field(changeset, :target_os) do
      :windows -> invalid_windows_path_message(path)
      :macos -> invalid_macos_path_message(path)
      _ -> nil
    end
  end

  defp invalid_windows_path_message(path) do
    if windows_path?(path),
      do: nil,
      else: "must be a valid Windows path like C:\\Projects\\my_app"
  end

  defp invalid_macos_path_message(path) do
    if macos_path?(path), do: nil, else: "must be an absolute or home-relative macOS path"
  end

  defp windows_path?(path),
    do: Regex.match?(~r/^[A-Za-z]:\\/, path) or String.starts_with?(path, "\\\\")

  defp macos_path?(path),
    do: String.starts_with?(path, "/") or String.starts_with?(path, "~/") or path == "~"
end
