defmodule ParpartyWeb.Event.Settings.GeneralLive do
  use ParpartyWeb, :live_view

  alias Parparty.Event

  @impl true
  def mount(params, _session, socket) do
    event = Event.get_event_by_guid!(params["guid"])
    {:ok, assign(socket, event: event)}
  end

  @impl true
  def handle_event("update", params, socket) do

    case Event.update_event(socket.assigns.event, params) do
      {:ok, _event} ->
        {:noreply,
          socket
          |> put_flash(:info, "#{params["name"]} has been updated.")
          |> redirect(to: "/events/#{socket.assigns.event.guid}/settings")}

      {:error, _result} ->
        {:noreply,
          socket
          |> put_flash(:error, "There were errors updating your event.")
          |> redirect(to: "/events/#{socket.assigns.event.guid}/settings")}
    end
  end

end
