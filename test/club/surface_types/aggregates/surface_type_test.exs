defmodule Club.SurfaceTypes.Aggregates.SurfaceTypeTest do
  use Club.AggregateCase,
    aggregate: Club.SurfaceTypes.Aggregates.SurfaceType

  alias Club.SurfaceTypes.Commands.{
    AddSurfaceType
  }

  alias Club.SurfaceTypes.Events.{
    SurfaceTypeAdded
  }

  setup do
    add_surface_type =
      :new_surface_type
      |> build()
      |> AddSurfaceType.new()
      |> Ecto.Changeset.apply_changes()

    surface_type_aggregate =
      build(:surface_type_aggregate, %{
        uuid: add_surface_type.surface_type_uuid,
        name: add_surface_type.name,
        product_count: 0
      })

    [add_surface_type: add_surface_type, surface_type: surface_type_aggregate]
  end

  describe "AddSurfaceType command" do
    @describetag :unit

    test "should return SurfaceTypeAdded event for the first time", %{
      add_surface_type: cmd,
      surface_type: surface_type
    } do
      surface_type_added = SurfaceTypeAdded.new(cmd)
      assert_events(cmd, [surface_type_added])
      assert_state(cmd, surface_type)
    end

    test "should return {:error, :surface_type_already_exists} on the second try", %{
      add_surface_type: cmd
    } do
      surface_type_added = SurfaceTypeAdded.new(cmd)
      assert_error([surface_type_added], cmd, {:error, :surface_type_already_exists})
    end
  end
end
