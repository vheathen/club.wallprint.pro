defmodule Club.SurfaceTypes.Projectors.UniquenessCache do
  use Commanded.Event.Handler,
    application: Club.Commanded,
    name: __MODULE__

  alias Club.SurfaceTypes.Events.SurfaceTypeDeleted

  def handle(%SurfaceTypeDeleted{surface_type_uuid: surface_type_uuid}, _metadata) do
    case Commanded.Middleware.Uniqueness.Adapter.get() do
      nil ->
        :ok

      adapter ->
        :ok = adapter.release(:name, surface_type_uuid, Club.SurfaceTypes)
    end
  end
end
