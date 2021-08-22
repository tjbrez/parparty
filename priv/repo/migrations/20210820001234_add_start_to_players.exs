defmodule Parparty.Repo.Migrations.AddTypeToEvent do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :start, :integer
    end
  end
end
