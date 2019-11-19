defmodule Club.Colors.Commands.RenameColorTest do
  use Club.CommandCase,
    command: Club.Colors.Commands.RenameColor,
    factory: :rename_color

  required_fields([
    :color_uuid,
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
      :color_uuid
    ]
  )

  basic_command_tests()
end
