defmodule Club.Brands.Commands.RenameBrandTest do
  use Club.CommandCase,
    command: Club.Brands.Commands.RenameBrand,
    factory: :rename_brand

  required_fields([
    :brand_uuid,
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
      :brand_uuid
    ]
  )

  basic_command_tests()
end
