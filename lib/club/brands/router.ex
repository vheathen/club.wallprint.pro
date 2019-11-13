defmodule Club.Brands.Router do
  use Commanded.Commands.Router

  alias Club.Brands.Aggregates.Brand

  alias Club.Brands.Commands.{
    AddBrand,
    RenameBrand,
    UpdateBrandUrl
  }

  identify(Brand, by: :brand_uuid, prefix: "brand-")

  dispatch(
    [
      AddBrand,
      RenameBrand,
      UpdateBrandUrl
    ],
    to: Brand
  )
end
