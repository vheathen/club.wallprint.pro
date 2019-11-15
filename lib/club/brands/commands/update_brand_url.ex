defmodule Club.Brands.Commands.UpdateBrandUrl do
  use Commanded.Command,
    brand_uuid: Ecto.UUID,
    url: :string

  import Club.Support.Validators

  @required_fields [
    :brand_uuid,
    :url
  ]

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
    |> validate_url(:url, allowed_schemes: ["http", "https"])
  end
end
