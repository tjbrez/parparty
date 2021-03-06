defmodule ParpartyWeb.Event.Players.LeaderboardLive do
  use ParpartyWeb, :live_view

  alias Parparty.Event
  alias Phoenix.PubSub

  @impl true
  def mount(params, _session, socket) do
    PubSub.subscribe(Parparty.PubSub, "leaderboard")

    event = Event.get_event_by_guid!(params["guid"], [:players, :course])
    {
      :ok, 
      assign(
        socket, 
        event: event, 
        leaderboard: get_leaderboard(event),
        close_url: close_url(params["close_url"], event.guid),
        nav_label: nav_label(params["close_url"]))}
  end

  def handle_info(:refresh, socket) do
    {:noreply,
      assign(
        socket,
        leaderboard: get_leaderboard(
          Event.get_event_by_guid!(socket.assigns.event.guid, [:players, :course])
        ))}
  end

  defp get_leaderboard(event) do
    event.players
      |> format_for_event_type(event.type)
      |> Enum.map(fn p -> {p.name, get_score(p.score, event.course), get_thru(p.score)} end)
      |> Enum.sort(&(elem(&1, 1) <= elem(&2, 1)))
      |> add_position()
  end

  defp format_for_event_type(players, "Best Ball") do
    teams = players 
      |> Enum.group_by(fn %{scorecard: x} -> x end)
      |> Enum.map(&build_best_ball_team(&1))
  end

  defp format_for_event_type(players, _type) do
    players
  end

  defp build_best_ball_team({_scorecard_num, players}) do
    combined_scores = Enum.map(players, fn p -> p.score end)
      |> Enum.reduce(%{}, fn score, acc -> merge_best_ball_scores(acc, score) end)

    combined_names = Enum.reduce(players, " ", fn p, names -> "#{names}, #{p.name}" end)
      |> String.replace(" , ", "")
    
    %{name: combined_names, score: combined_scores || %{}}
  end

  defp merge_best_ball_scores(acc, nil) do
    acc
  end

  defp merge_best_ball_scores(acc, score) do
    Map.merge(acc, score, fn _k, v1, v2 -> compare_best_ball_scores(v1,v2) end)
  end

  defp compare_best_ball_scores(score1, score2) do
    if String.to_integer(score1["strokes"]) < String.to_integer(score2["strokes"]), do: score1, else: score2
  end

  defp get_score(nil, _course) do
    0
  end

  defp get_score(%{} = score, course) do
    Enum.reduce(score, 0, fn {hole, hole_data}, total -> calc_total(hole, hole_data, total, course) end)
  end

  defp get_thru(nil) do
    0
  end

  defp get_thru(%{} = score) do
    map_size(score)
  end

  defp close_url(nil, guid) do
    "/events/#{guid}"
  end

  defp close_url(url, _guid) do
    url
  end

  defp nav_label(nil) do
    "Teams"
  end

  defp nav_label(url) do
    "Enter Scores"
  end

  defp close_url(url, _guid) do
    url
  end

  defp calc_total(hole, hole_data, total, course) do
    get_strokes_for_hole(hole_data) - get_par_for_hole(hole, course) + total
  end

  defp get_strokes_for_hole(hole_data) do
    String.to_integer(hole_data["strokes"])
  end

  defp get_par_for_hole(hole, course) do
    String.to_integer(course.holes[hole]["par"])
  end

  defp add_position(leaderboard) do
    leaderboard
      |> Enum.map_reduce({0, 0, nil}, fn {name, score, thru}, {pos, i, last} -> 
        i = i + 1
        pos = if score == last, do: pos, else: i
        # pos_display = if score == last, do: "", else: pos
        {{pos, name, score, thru}, {pos, i, score}} 
      end)
      |> elem(0)
  end
end
