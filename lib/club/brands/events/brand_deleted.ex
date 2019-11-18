defmodule Club.Brands.Events.BrandDeleted do
  use Commanded.Event,
    version: 1,
    from: Club.Brands.Commands.DeleteBrand
end
