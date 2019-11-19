defmodule Club.Colors.Commands.UseColorTest do
  use Club.CommandCase,
    command: Club.Colors.Commands.UseColor,
    factory: :use_color

  required_fields([
    :color_uuid,
    :thing_uuid
  ])

  fields(
    Ecto.UUID,
    [
      :color_uuid,
      :thing_uuid
    ]
  )

  basic_command_tests()
end
