defmodule Club.Brands.Commands.RenameBrandTest do
  use Club.CommandCase,
    command: Club.Brands.Commands.RenameBrand,
    factory: :rename_brand

  required_fields([
    :brand_uuid,
    :name,
    :user_uuid,
    :user_name
  ])

  fields(
    :string,
    [
      :name,
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
