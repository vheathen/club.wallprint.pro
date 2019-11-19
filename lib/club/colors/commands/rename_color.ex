defmodule Club.Colors.Commands.RenameColor do
  use Commanded.Command,
    color_uuid: Ecto.UUID,
    name: :string

  @required_fields [
    :color_uuid,
    :name
  ]

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
  end
end
