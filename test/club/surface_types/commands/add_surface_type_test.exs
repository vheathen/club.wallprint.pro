defmodule Club.SurfaceTypes.Commands.AddSurfaceTypeTest do
  use Club.CommandCase,
    command: Club.SurfaceTypes.Commands.AddSurfaceType,
    factory: :new_surface_type

  required_fields([
    :surface_type_uuid,
    :name
  ])

  fields(
    :string,
    [
      :name
    ]
  )

  fields(
    Ecto.UUID,
    [
      :surface_type_uuid
    ]
  )

  basic_command_tests()
end
