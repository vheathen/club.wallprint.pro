defmodule Club.Brands.Router do
  use Commanded.Commands.Router

  alias Club.Brands.Commands.AddBrand

  alias Club.Brands.Aggregates.Brand

  identify(Brand, by: :brand_uuid, prefix: "brand-")

  dispatch(
    [
      AddBrand
    ],
    to: Brand
  )
end
