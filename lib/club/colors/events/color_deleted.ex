defmodule Club.Colors.Events.ColorDeleted do
  use Commanded.Event,
    version: 1,
    from: Club.Colors.Commands.DeleteColor
end
