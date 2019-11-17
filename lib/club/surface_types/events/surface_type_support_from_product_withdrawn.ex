defmodule Club.SurfaceTypes.Events.SurfaceTypeSupportFromProductWithdrawn do
  use Commanded.Event,
    version: 1,
    from: Club.SurfaceTypes.Commands.WithdrawSurfaceTypeSupportFromProduct
end
