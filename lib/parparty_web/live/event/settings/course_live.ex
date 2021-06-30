defmodule ParpartyWeb.Event.Settings.CourseLive do
  use ParpartyWeb, :live_view

  alias Parparty.Event
  alias Parparty.Schemas.Course

  @impl true
  def mount(params, _session, socket) do
    event = Event.get_event_by_guid!(params["guid"], [:course])
    {:ok, assign(socket, event: event, course: get_course(event.course))}
  end

  @impl true
  def handle_event("upsert", params, socket) do

    params = params |> Map.put("holes", normalize_hole_data(params))
    case Event.upsert_course(socket.assigns.course, params) do
      {:ok, course} ->
        Event.update_event(socket.assigns.event, %{"course_id" => course.id})
        {:noreply,
          socket
          |> put_flash(:info, "#{course.name} has been setup")
          |> redirect(to: "/events/#{socket.assigns.event.guid}/settings")}

      {:error, _result} ->
        {:noreply,
          socket
          |> put_flash(:error, "There were errors creating your event.")
          |> redirect(to: "/events/#{socket.assigns.event.guid}/settings")}
    end
  end

  defp get_course(nil) do
    %Course{}
  end

  defp get_course(course) do
    course
  end

  defp normalize_hole_data(params) do
    Enum.reduce params, %{}, fn {k, v}, acc ->
      add_hole(String.contains?(k, "hole"), acc, k, v)
    end
  end

  defp add_hole(true, holes, k, v) do
    Map.put(holes, String.slice(k, 0, 6), %{"par" => v})
  end

  defp add_hole(false, holes, _k, _v) do
    holes
  end

end
