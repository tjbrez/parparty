defmodule ParpartyWeb.Event.NewLive do
  use ParpartyWeb, :live_view

  alias Parparty.Event

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, name: "", email: "")}
  end

  @impl true
  def handle_event("create", %{"name" => name, "email" => email} = params, socket) do

    case Event.create_event(params) do
      {:ok, _event} ->
        {:noreply,
          socket
          |> put_flash(:info, "#{name} has been created! Please check your email for next steps.")
          |> assign(name: "", email: email)}

      {:error, changeset} ->
        {:noreply,
          socket
          |> put_flash(:error, "There were errors creating your event.")
          |> assign(name: "", email: email)}
    end
  end

end
