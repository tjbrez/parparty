defmodule ParpartyWeb.Event.NewLive do
  use ParpartyWeb, :live_view

  alias Parparty.Event

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, name: "", email: "")}
  end

  @impl true
  def handle_event("create", %{"name" => name, "email" => email, "type" => type} = params, socket) do

    case Event.create_event(params) do
      {:ok, event} ->
        {:noreply,
          socket
          |> put_flash(:info, "#{name} has been created!")
          |> redirect(to: "/events/#{event.guid}/settings/")}

      {:error, changeset} ->
        {:noreply,
          socket
          |> put_flash(:error, "There were errors creating your event.")
          |> assign(name: "", email: email)}
    end
  end

end
