defmodule Club.Brands.Commands.UnlinkProductFromBrand do
  use Commanded.Command,
    brand_uuid: Ecto.UUID,
    product_uuid: Ecto.UUID

  @required_fields [
    :brand_uuid,
    :product_uuid
  ]

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
  end
end
