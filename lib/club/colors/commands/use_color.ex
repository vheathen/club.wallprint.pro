defmodule Club.Colors.Commands.UseColor do
  use Commanded.Command,
    color_uuid: Ecto.UUID,
    thing_uuid: Ecto.UUID

  @required_fields [
    :color_uuid,
    :thing_uuid
  ]

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
  end
end
