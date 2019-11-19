defmodule Club.Colors.Events.ColorUsed do
  use Commanded.Event,
    version: 1,
    from: Club.Colors.Commands.UseColor
end
