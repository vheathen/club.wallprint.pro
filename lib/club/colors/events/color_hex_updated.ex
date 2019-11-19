defmodule Club.Colors.Events.ColorHexUpdated do
  use Commanded.Event,
    version: 1,
    from: Club.Colors.Commands.UpdateColorHex
end
