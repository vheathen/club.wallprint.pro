defmodule Club.Colors.Events.ColorUsageStopped do
  use Commanded.Event,
    version: 1,
    from: Club.Colors.Commands.StopUsingColor
end
