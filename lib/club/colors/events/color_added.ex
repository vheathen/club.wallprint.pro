defmodule Club.Colors.Events.ColorAdded do
  use Commanded.Event,
    version: 1,
    from: Club.Colors.Commands.AddColor
end
