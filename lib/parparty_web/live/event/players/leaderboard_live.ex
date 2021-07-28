defmodule ParpartyWeb.Event.Players.LeaderboardLive do
  use ParpartyWeb, :live_view

  alias Parparty.Event

  @impl true
  def mount(params, _session, socket) do
    event = Event.get_event_by_guid!(params["guid"], [:players, :course])
    {:ok, assign(socket, event: event, leaderboard: get_leaderboard(event.players, event.course))}
  end

  defp get_leaderboard(players, course) do
    players
      |> Enum.map(fn p -> {p.name, get_score(p.score, course), get_thru(p.score)} end)
      |> Enum.sort(&(elem(&1, 1) <= elem(&2, 1)))
      |> add_position()
  end

  defp get_score(nil, _course) do
    0
  end

  defp get_score(%{} = score, course) do
    {_, score} = Enum.reduce(score, 0, fn {hole, hole_data}, total -> {hole, calc_total(hole, hole_data, total, course)} end)
    score
  end

  defp get_thru(nil) do
    0
  end

  defp get_thru(%{} = score) do
    map_size(score)
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
