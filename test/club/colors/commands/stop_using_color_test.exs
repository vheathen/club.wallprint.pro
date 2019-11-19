defmodule Club.Colors.Commands.StopUsingColorTest do
  use Club.CommandCase,
    command: Club.Colors.Commands.StopUsingColor,
    factory: :stop_using_color

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
