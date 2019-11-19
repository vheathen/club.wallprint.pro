defmodule Club.Colors.Router do
  use Club.Support.Router

  alias Club.Colors.Aggregates.Color

  alias Club.Colors.Commands.{
    AddColor,
    RenameColor,
    UpdateColorHex,
    UseColor,
    StopUsingColor,
    DeleteColor
  }

  identify(Color, by: :color_uuid, prefix: "color-")

  dispatch(
    [
      AddColor,
      RenameColor,
      UpdateColorHex,
      UseColor,
      StopUsingColor,
      DeleteColor
    ],
    to: Color
  )
end
