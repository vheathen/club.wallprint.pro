defmodule Club.SurfaceTypes.Events.SurfaceTypeDeleted do
  use Commanded.Event,
    version: 1,
    from: Club.SurfaceTypes.Commands.DeleteSurfaceType
end
