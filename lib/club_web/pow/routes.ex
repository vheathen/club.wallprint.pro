defmodule ClubWeb.Pow.Routes do
  use Pow.Phoenix.Routes
  alias ClubWeb.Router.Helpers, as: Routes

  def session_path(conn, :new), do: Routes.page_path(conn, :index)
  def registration_path(conn, :new), do: Routes.page_path(conn, :index)
  def registration_path(conn, :edit), do: Routes.page_path(conn, :index)
end
