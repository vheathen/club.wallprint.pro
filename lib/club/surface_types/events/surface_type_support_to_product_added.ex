defmodule Club.SurfaceTypes.Events.SurfaceTypeSupportToProductAdded do
  use Commanded.Event,
    version: 1,
    from: Club.SurfaceTypes.Commands.AddSurfaceTypeSupportToProduct
end
