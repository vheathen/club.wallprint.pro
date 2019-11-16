defmodule Club.SurfaceTypes.Aggregates.SurfaceType do
  @derive Jason.Encoder

  defstruct uuid: nil,
            name: nil,
            product_count: 0

  alias Club.SurfaceTypes.Aggregates.SurfaceType

  alias Club.SurfaceTypes.Commands.{
    AddSurfaceType,
    RenameSurfaceType
  }

  alias Club.SurfaceTypes.Events.{
    SurfaceTypeAdded,
    SurfaceTypeRenamed
  }

  # AddSurfaceType
  def execute(%SurfaceType{uuid: nil}, %AddSurfaceType{} = cmd), do: SurfaceTypeAdded.new(cmd)

  def execute(%SurfaceType{}, %AddSurfaceType{}), do: {:error, :surface_type_already_exists}

  # RenameSurfaceType
  def execute(%SurfaceType{uuid: nil}, %RenameSurfaceType{}),
    do: {:error, :surface_type_doesnt_exist}

  def execute(%SurfaceType{name: name}, %RenameSurfaceType{name: name}), do: nil

  def execute(%SurfaceType{uuid: uuid}, %RenameSurfaceType{surface_type_uuid: uuid} = cmd),
    do: SurfaceTypeRenamed.new(cmd)

  # state mutators

  # AddSurfaceType
  def apply(%SurfaceType{} = surface_type, %SurfaceTypeAdded{} = event) do
    %SurfaceType{
      surface_type
      | uuid: event.surface_type_uuid,
        name: event.name
    }
  end

  def apply(%SurfaceType{} = surface_type, %SurfaceTypeRenamed{name: name}) do
    %SurfaceType{
      surface_type
      | name: name
    }
  end
end
