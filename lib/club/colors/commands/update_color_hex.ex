defmodule Club.Colors.Commands.UpdateColorHex do
  use Commanded.Command,
    color_uuid: Ecto.UUID,
    hex: :string

  import Club.Support.Validators

  @required_fields [
    :color_uuid,
    :hex
  ]

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
    |> validate_format(:hex, ~r/[0-9a-f]{6}/)
  end
end
