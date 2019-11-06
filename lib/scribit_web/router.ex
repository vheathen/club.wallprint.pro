defmodule ScribitWeb.Router do
  use ScribitWeb, :router
  use Pow.Phoenix.Router
  use PowAssent.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
  end

  scope "/" do
    pipe_through :browser
    pow_session_routes()
    pow_assent_routes()
  end

  scope "/", ScribitWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/", ScribitWeb do
    pipe_through :browser

    live "/test_live", TestLive, session: [:scribit_auth]
  end

  # Other scopes may use custom stacks.
  # scope "/api", ScribitWeb do
  #   pipe_through :api
  # end
end
