defmodule Parparty.Schemas.Event do
    use Ecto.Schema
    import Ecto.Changeset
    alias Parparty.Schemas.Event
    alias Parparty.Schemas.Course
    alias Parparty.Schemas.Player
  
  
    schema "events" do
      field :name, :string
      field :email, :string
      field :guid, Ecto.UUID
      field :settings_code, :integer

      belongs_to :course, Course, [on_replace: :update]
      has_many :players, Player, preload_order: [asc: :scorecard, asc: :name]
  
      timestamps()
    end
  
    @doc false
    def changeset(%Event{} = event, attrs) do
      event
      |> cast(attrs, [:name, :email, :guid, :settings_code, :course_id])
      |> validate_required([:name, :email, :guid, :settings_code])
    end
  end