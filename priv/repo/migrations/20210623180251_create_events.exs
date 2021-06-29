defmodule Parparty.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :guid, :uuid, null: false
      add :settings_code, :integer, null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
