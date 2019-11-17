defmodule Club.SurfaceTypes.Router do
  use Club.Support.Router

  alias Club.SurfaceTypes.Aggregates.SurfaceType

  alias Club.SurfaceTypes.Commands.{
    AddSurfaceType,
    RenameSurfaceType,
    AddSurfaceTypeSupportToProduct,
    WithdrawSurfaceTypeSupportFromProduct
  }

  identify(SurfaceType, by: :surface_type_uuid, prefix: "surface_type-")

  dispatch(
    [
      AddSurfaceType,
      RenameSurfaceType,
      AddSurfaceTypeSupportToProduct,
      WithdrawSurfaceTypeSupportFromProduct
    ],
    to: SurfaceType
  )
end
