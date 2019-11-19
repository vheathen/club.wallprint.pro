defmodule Club.Colors.Events.ColorRenamed do
  use Commanded.Event,
    version: 1,
    from: Club.Colors.Commands.RenameColor
end
