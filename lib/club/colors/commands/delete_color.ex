defmodule Club.Colors.Commands.DeleteColor do
  use Commanded.Command,
    color_uuid: Ecto.UUID

  @required_fields [
    :color_uuid
  ]

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
  end
end
