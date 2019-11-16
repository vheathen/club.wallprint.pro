defmodule Club.Brands.Events.NewProductWithBrandLinked do
  use Commanded.Event,
    version: 1,
    from: Club.Brands.Commands.LinkNewProductWithBrand
end
