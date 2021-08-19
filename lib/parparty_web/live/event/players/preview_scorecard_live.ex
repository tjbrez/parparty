defmodule ParpartyWeb.Event.Players.PreviewScorecardLive do
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
        players: get_scorecard_players(event.players, params["scorecard_num"], event.course), 
        scorecard_num: params["scorecard_num"], 
        course_details: course_details(event.course), 
        enter_scores_base_url: "/events/#{event.guid}/scorecards/#{params["scorecard_num"]}")}
  end

  defp get_scorecard_players(players, num, course) do
    players 
      |> Enum.filter(fn player -> player.scorecard == num |> String.to_integer end)
      |> Enum.map(fn p -> Map.put_new(p, :front_score, get_front_strokes_for_player(p)) end)
      |> Enum.map(fn p -> Map.put_new(p, :back_score, get_back_strokes_for_player(p)) end)
      |> Enum.map(fn p -> Map.put_new(p, :to_par, get_to_par_for_player(p, course)) end)
  end

  defp get_front_strokes_for_player(%{score: nil}) do
    0
  end

  defp get_front_strokes_for_player(%{score: score}) do
    front_holes_keys()
      |> Enum.reduce(0, fn key, total -> total + get_score_as_int(score[key]["strokes"]) end)
  end

  defp get_back_strokes_for_player(%{score: nil}) do
    0
  end

  defp get_back_strokes_for_player(%{score: score}) do
    back_holes_keys()
      |> Enum.reduce(0, fn key, total -> total + get_score_as_int(score[key]["strokes"]) end)
  end

  defp get_to_par_for_player(%{score: nil}, _course) do
    0
  end

  defp get_to_par_for_player(%{score: score}, course) do
    Enum.reduce(score, 0, fn {hole, hole_data}, total -> calc_to_par_for_hole(hole, hole_data, total, course) end)
  end

  defp calc_to_par_for_hole(hole, hole_data, total, course) do
    get_strokes_for_hole(hole_data) - get_par_for_hole(hole, course) + total
  end

  defp get_strokes_for_hole(hole_data) do
    String.to_integer(hole_data["strokes"])
  end

  defp get_par_for_hole(hole, course) do
    String.to_integer(course.holes[hole]["par"])
  end

  defp course_details(course) do
    front = sum_front_holes(course.holes)
    back = sum_back_holes(course.holes)

    %{:front_total => front, :back_total => back, :total => front + back}
  end

  defp sum_front_holes(holes) do
    front_holes_keys()
      |> Enum.reduce(0, fn key, total -> total + get_score_as_int(holes[key]["par"]) end)
  end

  defp sum_back_holes(holes) do
    back_holes_keys()
      |> Enum.reduce(0, fn key, total -> total + get_score_as_int(holes[key]["par"]) end)
  end

  defp get_score_as_int(nil) do
    0
  end

  defp get_score_as_int(score) do
    String.to_integer(score)
  end

  defp front_holes_keys() do
    ["hole01", "hole02", "hole03", "hole04", "hole05", "hole06", "hole07", "hole08", "hole09"]
  end

  defp back_holes_keys() do
    ["hole10", "hole11", "hole12", "hole13", "hole14", "hole15", "hole16", "hole17", "hole18"]
  end
end
