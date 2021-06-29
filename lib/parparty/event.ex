defmodule Parparty.Event do
    @moduledoc """
    The Event context.
    """
  
    import Ecto.Query, warn: false
    alias Parparty.Repo
    alias Parparty.Schemas.Event, as: EventSchema
    alias Parparty.Schemas.Course, as: CourseSchema

    def get_event!(id), do: Repo.get!(EventSchema, id)

    def get_event_by_guid!(guid), do: Repo.get_by!(EventSchema, guid: guid) |> Repo.preload([:course])

    def create_event(attrs \\ %{}) do
      attrs = Map.merge(
        attrs, 
        %{"guid" => Ecto.UUID.generate(), "settings_code" => Enum.random(111_111..999_999)}
      )

      %EventSchema{}
      |> EventSchema.changeset(attrs)
      |> Repo.insert()
    end

    def update_event(event, attrs \\ %{}) do
      event
      |> EventSchema.changeset(attrs)
      |> Repo.update()
    end

    def upsert_course(course, attrs \\ %{}) do
      course
      |> CourseSchema.changeset(attrs)
      |> Repo.insert_or_update()
    end

  
    # def subscribe do
    #   Phoenix.PubSub.subscribe(Demo.PubSub, "posts")
    # end
  
    # defp broadcast({:error, _reason} = error, _event), do: error
  
    # defp broadcast({:ok, post}, event) do
    #   Phoenix.PubSub.broadcast(Demo.PubSub, "posts", {event, post})
    #   {:ok, post}
    # end
  
  end