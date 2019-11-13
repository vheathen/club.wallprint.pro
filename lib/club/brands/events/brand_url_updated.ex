defmodule Club.Brands.Events.BrandUrlUpdated do
  use Commanded.Event,
    version: 1,
    from: Club.Brands.Commands.UpdateBrandUrl
end
