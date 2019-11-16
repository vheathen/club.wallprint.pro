defmodule Club.SurfaceTypes.Events.SurfaceTypeRenamed do
  use Commanded.Event,
    version: 1,
    from: Club.SurfaceTypes.Commands.RenameSurfaceType
end
