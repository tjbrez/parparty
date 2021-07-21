defmodule ParpartyWeb.Event.Players.ScorecardsLive do
  use ParpartyWeb, :live_view

  alias Parparty.Event

  @impl true
  def mount(params, _session, socket) do
    event = Event.get_event_by_guid!(params["guid"], [:players])
    {:ok, assign(socket, event: event, scorecards: get_scorecards(event.players))}
  end

  defp get_scorecards(players) do
    players |> Enum.group_by(fn %{scorecard: x} -> x end)
  end

end
