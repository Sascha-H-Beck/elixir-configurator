defmodule Elixirmachine.Repo.Migrations.AddConfigurationToGenerations do
  use Ecto.Migration

  def change do
    alter table(:generations) do
      add :configuration, :map, null: false, default: %{}
    end
  end
end
