defmodule Club.Brands.Commands.LinkNewProductWithBrandTest do
  use Club.CommandCase,
    command: Club.Brands.Commands.LinkNewProductWithBrand,
    factory: :link_new_product_with_brand

  required_fields([
    :brand_uuid,
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
      :brand_uuid,
      :product_uuid
    ]
  )

  basic_command_tests()
end
