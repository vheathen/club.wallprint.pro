defmodule Club.Brands.Commands.DeleteBrandTest do
  use Club.CommandCase,
    command: Club.Brands.Commands.DeleteBrand,
    factory: :delete_brand

  required_fields([
    :brand_uuid
  ])

  fields(
    Ecto.UUID,
    [
      :brand_uuid
    ]
  )

  basic_command_tests()
end
