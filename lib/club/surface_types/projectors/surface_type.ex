defmodule Club.SurfaceTypes.Projectors.SurfaceType do
  use Commanded.Projections.Ecto,
    application: Club.Commanded,
    repo: Club.ReadRepo,
    name: "surface_types_surface_type"

  alias Club.SurfaceTypes.Projections.SurfaceType

  alias Club.SurfaceTypes.Events.{
    SurfaceTypeAdded
    # SurfaceTypeRenamed
  }

  project(%SurfaceTypeAdded{} = surface_type_added, _meta, fn multi ->
    Ecto.Multi.insert(
      multi,
      :surface_type,
      %SurfaceType{
        surface_type_uuid: surface_type_added.surface_type_uuid,
        name: surface_type_added.name,
        product_count: 0
      }
    )
  end)

  def after_update(
        %SurfaceTypeAdded{surface_type_uuid: surface_type_uuid, name: name},
        _metadata,
        _changes
      ) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      "domain:surface_types",
      {:surface_type_added, %{surface_type_uuid: surface_type_uuid, name: name}}
    )

    :ok
  end

  # project(
  #   %SurfaceTypeRenamed{surface_type_uuid: surface_type_uuid, name: name},
  #   _meta,
  #   fn multi ->
  #     update_surface_type(multi, surface_type_uuid, name: name)
  #   end
  # )

  # def after_update(
  #       %SurfaceTypeRenamed{surface_type_uuid: surface_type_uuid, name: name},
  #       _metadata,
  #       _changes
  #     ) do
  #   Phoenix.PubSub.broadcast(
  #     Club.EventBus,
  #     "domain:surface_types",
  #     {:surface_type_renamed, %{surface_type_uuid: surface_type_uuid, name: name}}
  #   )

  #   :ok
  # end

  # defp update_surface_type(multi, surface_type_uuid, changes) do
  #   Ecto.Multi.update_all(multi, :surface_type, surface_type_query(surface_type_uuid),
  #     set: changes
  #   )
  # end

  # defp surface_type_query(surface_type_uuid) do
  #   from b in SurfaceType, where: b.surface_type_uuid == ^surface_type_uuid
  # end
end
