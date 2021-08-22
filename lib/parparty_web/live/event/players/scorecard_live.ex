defmodule ParpartyWeb.Event.Players.ScorecardLive do
  use ParpartyWeb, :live_view

  alias Parparty.Event
  alias Phoenix.PubSub

  @impl true
  def mount(params, _session, socket) do

    event = Event.get_event_by_guid!(params["guid"], [:course, players: [:event]])
    players = get_scorecard_players(event.players, params["scorecard_num"])
    hole_num = get_hole_num(params["hole"], List.first(players))
    scorecard_num = params["scorecard_num"]

    case hole_num do
      num when num > 18 -> 
        {:ok,
          socket 
          |> redirect(to: "/events/#{event.guid}/scorecards/#{scorecard_num}?hole=1")}
      num when num < 1 -> 
        {:ok,
          socket 
          |> redirect(to: "/events/#{event.guid}/scorecards/#{scorecard_num}?hole=18")}
      _ -> 
        {:ok,
        assign(socket,
          event: event,
          players: get_scorecard_players(event.players, scorecard_num),
          scorecard_num: scorecard_num,
          hole_num: hole_num,
          hole_data: get_hole_data(hole_num, event.course.holes),
          hole_key: get_hole_key(hole_num),
        )}
    end 
  end

  @impl true
  def handle_event("save", params, socket) do
    Enum.each params, fn {player_id, score} ->
      socket |> get_player(player_id) |> save_player_score(score, socket.assigns.hole_key)
    end

    PubSub.broadcast(Parparty.PubSub, "leaderboard", :refresh)

    {:noreply,
      socket
      |> redirect(to: "/events/#{socket.assigns.event.guid}/scorecards/#{socket.assigns.scorecard_num}?hole=#{socket.assigns.hole_num + 1}")}
  end

  defp get_scorecard_players(players, num) do
    players |> Enum.filter(fn player -> player.scorecard == num |> String.to_integer end)
  end

  defp get_hole_num(nil, %{score: score} = player) do
    hole_keys = score |> normalize_score |> Map.keys 
    case hole_keys |> length do
      0 -> player.start
      _hole -> (hole_keys |> List.last |> String.slice(4, 6) |> String.to_integer()) + 1
    end
  end

  defp get_hole_num(hole, _players) do
    String.to_integer(hole)
  end

  defp get_hole_data(hole_num, holes) do
    key = hole_num |> get_hole_key()
    holes |> Map.get(key)
  end

  defp get_hole_key(hole_num) do
    hole_num |> Integer.to_string |> String.pad_leading(6, "hole0")
  end

  defp normalize_score(nil) do
    %{}
  end

  defp normalize_score(score) do
    score
  end

  defp get_player(socket, player_id) do
    Enum.find(
      socket.assigns.players, 
      fn p -> 
        p.id == String.to_integer(player_id) 
      end) 
  end

  defp save_player_score(player, "", hole_key) do
    score = %{"score": player.score |> normalize_score() |> Map.delete(hole_key)}
    player |> Event.upsert_player(score)
  end

  defp save_player_score(player, score, hole_key) do
    score = %{"score": player.score |> normalize_score() |> Map.put(hole_key, %{strokes: score})}
    player |> Event.upsert_player(score)
  end
end
