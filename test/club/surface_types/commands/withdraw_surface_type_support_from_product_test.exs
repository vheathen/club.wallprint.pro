defmodule Club.SurfaceTypes.Commands.WithdrawSurfaceTypeSupportFromProductTest do
  use Club.CommandCase,
    command: Club.SurfaceTypes.Commands.WithdrawSurfaceTypeSupportFromProduct,
    factory: :withdraw_surface_type_support_from_product

  required_fields([
    :surface_type_uuid,
    :product_uuid
  ])

  fields(
    Ecto.UUID,
    [
      :surface_type_uuid,
      :product_uuid
    ]
  )

  basic_command_tests()
end
