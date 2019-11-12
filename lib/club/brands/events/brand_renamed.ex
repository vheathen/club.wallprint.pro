defmodule Club.Brands.Events.BrandRenamed do
  use Commanded.Event,
    version: 1,
    from: Club.Brands.Commands.RenameBrand
end
