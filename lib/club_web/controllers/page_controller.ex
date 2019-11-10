defmodule ClubWeb.PageController do
  use ClubWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
