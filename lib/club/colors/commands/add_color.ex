defmodule Club.Colors.Commands.AddColor do
  use Commanded.Command,
    color_uuid: Ecto.UUID,
    name: :string,
    hex: :string

  @required_fields [
    :color_uuid,
    :name,
    :hex
  ]

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
    |> validate_format(:hex, ~r/[0-9a-f]{6}/)
  end
end
