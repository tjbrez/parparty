defmodule Parparty.Event do
    @moduledoc """
    The Event context.
    """
  
    import Ecto.Query, warn: false
    alias Parparty.Repo
    alias Parparty.Schemas.Event, as: EventSchema
    alias Parparty.Schemas.Course, as: CourseSchema
    alias Parparty.Schemas.Player, as: PlayerSchema

    def get_event!(id), do: Repo.get!(EventSchema, id)

    def get_event_by_guid!(guid, preloads \\ []) do
      Repo.get_by!(EventSchema, guid: guid) |> Repo.preload(preloads)
    end

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

    def upsert_player(player, attrs \\ %{}) do
      update_starting_hole_for_players(
        attrs["start"], 
        player.event.id, 
        player.scorecard || attrs["scorecard"])

      player
      |> PlayerSchema.changeset(attrs)
      |> Repo.insert_or_update()
    end

    def delete_player(player) do
      player |> Repo.delete()
    end

    def update_starting_hole_for_players(nil, _event_id, _scorecard) do
      #no-op
    end

    def update_starting_hole_for_players("", event_id, scorecard) do
      from(p in PlayerSchema, where: p.event_id == ^event_id and p.scorecard == ^scorecard)
      |> Repo.update_all(set: [start: nil])
    end

    def update_starting_hole_for_players(start, event_id, scorecard) do
      from(p in PlayerSchema, where: p.event_id == ^event_id and p.scorecard == ^scorecard)
      |> Repo.update_all(set: [start: String.to_integer(start)])
    end

  end