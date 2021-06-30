defmodule ParpartyWeb.Event.Settings.PlayersLive do
  use ParpartyWeb, :live_view

  alias Parparty.Event
  alias Parparty.Schemas.Player

  @impl true
  def mount(params, _session, socket) do
    event = Event.get_event_by_guid!(params["guid"], [:players])
    {:ok, 
      assign(
        socket, 
        event: event, 
        players: event.players, 
        player: set_player(params, event.players, event))}
  end

  @impl true
  def handle_event("upsert_player", params, socket) do
    case socket |> get_player |> Event.upsert_player(params) do
      {:ok, _player} ->
        {:noreply,
          socket
          |> redirect(to: "/events/#{socket.assigns.event.guid}/settings/players")}

      {:error, _result} ->
        {:noreply,
          socket
          |> put_flash(:error, "There were errors creating the player.")
          |> redirect(to: "/events/#{socket.assigns.event.guid}/settings/players")}
    end
  end

  @impl true
  def handle_event("delete_player", params, socket) do
    case socket |> get_player |> Event.delete_player do
      {:ok, _player} ->
        {:noreply,
          socket
          |> redirect(to: "/events/#{socket.assigns.event.guid}/settings/players")}

      {:error, _result} ->
        {:noreply,
          socket
          |> put_flash(:error, "There were errors deleting the player.")
          |> redirect(to: "/events/#{socket.assigns.event.guid}/settings/players")}
    end
  end

  defp get_player(socket) do
    socket.assigns.player || %Player{:event => socket.assigns.event}
  end

  defp set_player(%{"id" => id, "type" => "edit"} = params, players, event) do
    Enum.find(players, fn p -> p.id == String.to_integer(id) end) |> Map.put(:event, event)
  end

  defp set_player(_, _, _) do
    nil
  end

end
