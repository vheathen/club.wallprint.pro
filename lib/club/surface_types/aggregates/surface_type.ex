defmodule Club.SurfaceTypes.Aggregates.SurfaceType do
  @derive Jason.Encoder

  defstruct uuid: nil,
            name: nil,
            product_count: 0

  alias Club.SurfaceTypes.Aggregates.SurfaceType

  alias Club.SurfaceTypes.Commands.{
    AddSurfaceType
  }

  alias Club.SurfaceTypes.Events.{
    SurfaceTypeAdded
  }

  # AddSurfaceType
  def execute(%SurfaceType{uuid: nil}, %AddSurfaceType{} = cmd), do: SurfaceTypeAdded.new(cmd)

  def execute(%SurfaceType{}, %AddSurfaceType{}), do: {:error, :surface_type_already_exists}

  # state mutators

  # AddSurfaceType
  def apply(%SurfaceType{} = surface_type, %SurfaceTypeAdded{} = event) do
    %SurfaceType{
      surface_type
      | uuid: event.surface_type_uuid,
        name: event.name
    }
  end
end
