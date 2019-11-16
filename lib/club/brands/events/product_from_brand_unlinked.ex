defmodule Club.Brands.Events.ProductFromBrandUnlinked do
  use Commanded.Event,
    version: 1,
    from: Club.Brands.Commands.UnlinkProductFromBrand
end
