defmodule ParpartyWeb.Event.Players.MenuLive do
  use ParpartyWeb, :live_view

  alias Parparty.Event

  @impl true
  def mount(params, _session, socket) do
    event = Event.get_event_by_guid!(params["guid"])
    {:ok, assign(socket, name: event.name, guid: event.guid)}
  end

end
