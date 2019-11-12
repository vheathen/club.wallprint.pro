defmodule Club.Brands.Events.BrandAdded do
  use Commanded.Event,
    version: 1,
    from: Club.Brands.Commands.AddBrand
end
