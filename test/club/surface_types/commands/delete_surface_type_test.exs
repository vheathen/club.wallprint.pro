defmodule Club.SurfaceTypes.Commands.DeleteSurfaceTypeTest do
  use Club.CommandCase,
    command: Club.SurfaceTypes.Commands.DeleteSurfaceType,
    factory: :delete_surface_type

  required_fields([
    :surface_type_uuid
  ])

  fields(
    Ecto.UUID,
    [
      :surface_type_uuid
    ]
  )

  basic_command_tests()
end
