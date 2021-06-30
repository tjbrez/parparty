defmodule Parparty.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :name, :string, null: false
      add :scorecard, :integer, null: false
      add :handicap, :integer
      add :score, :map
      add :event_id, references("events")

      timestamps(type: :utc_datetime_usec)
    end
  end
end
