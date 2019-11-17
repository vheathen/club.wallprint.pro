defmodule Club.SurfaceTypes.Commands.AddSurfaceTypeSupportToProductTest do
  use Club.CommandCase,
    command: Club.SurfaceTypes.Commands.AddSurfaceTypeSupportToProduct,
    factory: :add_surface_type_support_to_product

  required_fields([
    :surface_type_uuid,
    :product_uuid
  ])

  optional_fields([
    :product_name
  ])

  fields(
    :string,
    [
      :product_name
    ]
  )

  fields(
    Ecto.UUID,
    [
      :surface_type_uuid,
      :product_uuid
    ]
  )

  basic_command_tests()
end
