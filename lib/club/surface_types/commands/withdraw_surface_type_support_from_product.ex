defmodule Club.SurfaceTypes.Commands.WithdrawSurfaceTypeSupportFromProduct do
  use Commanded.Command,
    surface_type_uuid: Ecto.UUID,
    product_uuid: Ecto.UUID

  @required_fields [
    :surface_type_uuid,
    :product_uuid
  ]

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
  end
end
