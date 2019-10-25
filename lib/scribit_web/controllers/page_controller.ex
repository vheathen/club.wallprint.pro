defmodule ScribitWeb.PageController do
  use ScribitWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
