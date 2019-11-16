defmodule Club.Brands.Router do
  use Club.Support.Router

  alias Club.Brands.Aggregates.Brand

  alias Club.Brands.Commands.{
    AddBrand,
    RenameBrand,
    UpdateBrandUrl,
    LinkNewProductWithBrand,
    UnlinkProductFromBrand
  }

  identify(Brand, by: :brand_uuid, prefix: "brand-")

  dispatch(
    [
      AddBrand,
      RenameBrand,
      UpdateBrandUrl,
      LinkNewProductWithBrand,
      UnlinkProductFromBrand
    ],
    to: Brand
  )
end
