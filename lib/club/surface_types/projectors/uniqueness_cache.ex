defmodule Club.SurfaceTypes.Projectors.UniquenessCache do
  use Commanded.Event.Handler,
    application: Club.Commanded,
    name: __MODULE__

  alias Club.Support.Config

  alias Club.SurfaceTypes.Events.SurfaceTypeDeleted

  def handle(%SurfaceTypeDeleted{surface_type_uuid: surface_type_uuid}, _metadata) do
    case Config.get_sub(Club.Support.Unique, :adapter) do
      nil ->
        :ok

      adapter ->
        :ok = adapter.release(:name, surface_type_uuid)
    end
  end
end
