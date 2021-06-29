defmodule ParpartyWeb.Router do
  use ParpartyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ParpartyWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ParpartyWeb do
    pipe_through :browser

    # New Event
    live "/", Event.NewLive, :index

    # Player View
    live "/events/:guid", Event.Players.MenuLive, :index

    # Settings View
    live "/events/:guid/settings", Event.Settings.MenuLive, :index
    live "/events/:guid/settings/general", Event.Settings.GeneralLive, :index
    live "/events/:guid/settings/course", Event.Settings.CourseLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", ParpartyWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ParpartyWeb.Telemetry
    end
  end
end
