defmodule Club.Brands.Commands.UnlinkProductFromBrandTest do
  use Club.CommandCase,
    command: Club.Brands.Commands.UnlinkProductFromBrand,
    factory: :unlink_product_from_brand

  required_fields([
    :brand_uuid,
    :product_uuid
  ])

  fields(
    Ecto.UUID,
    [
      :brand_uuid,
      :product_uuid
    ]
  )

  basic_command_tests()
end
