defmodule Parparty.Repo.Migrations.AddCourseToEventsTable do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :course_id, references("courses")
    end
  end
end
