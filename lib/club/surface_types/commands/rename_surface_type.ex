defmodule Club.SurfaceTypes.Commands.RenameSurfaceType do
  use Commanded.Command,
    surface_type_uuid: Ecto.UUID,
    name: :string

  @required_fields [
    :surface_type_uuid,
    :name
  ]

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
  end
end

defimpl Commanded.Middleware.Uniqueness.UniqueFields,
  for: Club.SurfaceTypes.Commands.RenameSurfaceType do
  alias Club.SurfaceTypes.Commands.RenameSurfaceType
  alias Club.SurfaceTypes

  def unique(%RenameSurfaceType{surface_type_uuid: surface_type_uuid}),
    do: [
      {:name, "has already exist", surface_type_uuid,
       ignore_case: true,
       label: :surface_type,
       is_unique: &is_unique/4,
       partition: Club.SurfaceTypes}
    ]

  def is_unique(:name, value, _owner, _opts),
    do: SurfaceTypes.surface_type_unique?(%{name: value})
end
