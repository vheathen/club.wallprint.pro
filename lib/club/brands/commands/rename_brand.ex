defmodule Club.Brands.Commands.RenameBrand do
  use Commanded.Command,
    brand_uuid: Ecto.UUID,
    brand_new_name: :string,
    user_uuid: Ecto.UUID,
    user_name: :string

  @required_fields [
    :brand_uuid,
    :brand_new_name,
    :user_uuid,
    :user_name
  ]

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
  end
end
