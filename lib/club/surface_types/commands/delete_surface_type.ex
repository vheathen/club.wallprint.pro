defmodule Club.SurfaceTypes.Commands.DeleteSurfaceType do
  use Commanded.Command,
    surface_type_uuid: Ecto.UUID

  @required_fields [
    :surface_type_uuid
  ]

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
  end
end
