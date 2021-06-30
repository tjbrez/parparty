defmodule Parparty.Schemas.Player do
    use Ecto.Schema
    import Ecto.Changeset
    alias Parparty.Schemas.Player
    alias Parparty.Schemas.Event
  
  
    schema "players" do
      field :name, :string
      field :scorecard, :integer
      field :handicap, :integer
      field :score, :map

      belongs_to :event, Event
  
      timestamps()
    end
  
    @doc false
    def changeset(%Player{} = player, attrs) do
      player
      |> cast(attrs, [:name, :scorecard, :handicap, :score])
      |> validate_required([:name, :scorecard, :event])
    end
  end