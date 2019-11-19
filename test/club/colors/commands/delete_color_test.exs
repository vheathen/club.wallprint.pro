defmodule Club.Colors.Commands.DeleteColorTest do
  use Club.CommandCase,
    command: Club.Colors.Commands.DeleteColor,
    factory: :delete_color

  required_fields([
    :color_uuid
  ])

  fields(
    Ecto.UUID,
    [
      :color_uuid
    ]
  )

  basic_command_tests()
end
