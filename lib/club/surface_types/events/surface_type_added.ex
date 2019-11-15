defmodule Club.SurfaceTypes.Events.SurfaceTypeAdded do
  use Commanded.Event,
    version: 1,
    from: Club.SurfaceTypes.Commands.AddSurfaceType
end
