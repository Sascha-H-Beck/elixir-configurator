defmodule Elixirmachine.Repo.Migrations.CreateGenerations do
  use Ecto.Migration

  def change do
    create table(:generations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :project_name, :string, null: false
      add :project_type, :string, null: false
      add :target_os, :string, null: false
      add :output_path, :string, null: false
      add :features, {:array, :string}, null: false, default: []
      add :api_key_hash, :string, null: false
      add :script_content, :text
      add :script_filename, :string
      add :status, :string, null: false, default: "pending"
      add :error_message, :text

      timestamps(type: :utc_datetime)
    end

    create index(:generations, [:status])
  end
end
