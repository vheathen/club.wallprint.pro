defmodule Club.Devices.Commands.AddDevice do
  use Commanded.Command,
    device_uuid: Ecto.UUID,
    model: :string,
    sku: :string,
    url: :string,
    description: :string,
    brand_uuid: Ecto.UUID,
    brand_name: :string

  import Club.Support.Validators

  @required_fields [
    :device_uuid,
    :model,
    :brand_uuid,
    :brand_name
  ]

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
    |> validate_url(:url, allowed_schemes: ["http", "https"])
  end
end
