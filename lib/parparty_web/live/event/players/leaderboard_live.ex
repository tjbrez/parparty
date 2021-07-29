defmodule ParpartyWeb.Event.Players.LeaderboardLive do
  use ParpartyWeb, :live_view

  alias Parparty.Event

  @impl true
  def mount(params, _session, socket) do
    event = Event.get_event_by_guid!(params["guid"], [:players, :course])
    {
      :ok, 
      assign(
        socket, 
        event: event, 
        leaderboard: get_leaderboard(event),
        close_url: close_url(params["close_url"], event.guid))}
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

  defp build_best_ball_team({_scorecard_num, players}) do
    combined_scores = Enum.map(players, fn p -> p.score end)
     |> Enum.min_by(fn scores -> scores["hole01"]["strokes"] end)

    combined_names = Enum.reduce(players, " ", fn p, names -> "#{names}, #{p.name}" end)
      |> String.replace(" , ", "")
    
    %{name: combined_names, score: combined_scores || %{}}
  end

  defp format_for_event_type(players, _type) do
    players
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
