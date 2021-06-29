defmodule Parparty.Schemas.Course do
    use Ecto.Schema
    import Ecto.Changeset
    alias Parparty.Schemas.Course
    alias Parparty.Schemas.Event
  
  
    schema "courses" do
      field :name, :string
      field :holes, :map

      has_many :events, Event
  
      timestamps()
    end
  
    @doc false
    def changeset(%Course{} = course, attrs) do
      course
      |> cast(attrs, [:name, :holes])
      |> validate_required([:name, :holes])
    end
  end