defmodule Club.Brands.Commands.RenameBrandTest do
  use Club.CommandCase,
    command: Club.Brands.Commands.RenameBrand,
    factory: :rename_brand

  required_fields([
    :brand_uuid,
    :brand_name,
    :user_uuid,
    :user_name
  ])

  fields(
    :string,
    [
      :brand_name,
      :user_name
    ]
  )

  fields(
    Ecto.UUID,
    [
      :brand_uuid,
      :user_uuid
    ]
  )

  basic_command_tests()
end
