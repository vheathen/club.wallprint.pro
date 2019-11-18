defmodule Club.Brands.Commands.DeleteBrand do
  use Commanded.Command,
    brand_uuid: Ecto.UUID

  @required_fields [
    :brand_uuid
  ]

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
  end
end
