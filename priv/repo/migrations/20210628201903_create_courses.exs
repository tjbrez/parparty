defmodule Parparty.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :name, :string, null: false
      add :holes, :map, null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
