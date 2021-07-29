defmodule Parparty.Repo.Migrations.AddTypeToEvent do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :type, :string, null: false, default: "Stroke"
    end
  end
end
