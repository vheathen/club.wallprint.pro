defmodule Club.SurfaceTypes.Aggregates.SurfaceTypeTest do
  use Club.AggregateCase,
    aggregate: Club.SurfaceTypes.Aggregates.SurfaceType

  alias Club.SurfaceTypes.Commands.{
    AddSurfaceType,
    RenameSurfaceType
  }

  alias Club.SurfaceTypes.Events.{
    SurfaceTypeAdded,
    SurfaceTypeRenamed
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

  describe "RenameSurfaceType command" do
    @describetag :unit

    setup %{add_surface_type: add_surface_type, surface_type: surface_type} do
      rename_surface_type =
        :rename_surface_type
        |> build(surface_type_uuid: add_surface_type.surface_type_uuid)
        |> RenameSurfaceType.new()
        |> Ecto.Changeset.apply_changes()

      surface_type = %{surface_type | name: rename_surface_type.name}

      [
        add_surface_type: add_surface_type,
        rename_surface_type: rename_surface_type,
        surface_type: surface_type
      ]
    end

    test "should return SurfaceTypeRenamed event for the existing surface_type", %{
      add_surface_type: add_surface_type,
      rename_surface_type: rename_surface_type,
      surface_type: surface_type
    } do
      surface_type_added = SurfaceTypeAdded.new(add_surface_type)
      surface_type_renamed = SurfaceTypeRenamed.new(rename_surface_type)
      assert_events([surface_type_added], rename_surface_type, [surface_type_renamed])
      assert_state([surface_type_added], rename_surface_type, surface_type)
    end

    test "should return {:error, :surface_type_doesnt_exist} if no such surface_type exists", %{
      rename_surface_type: rename_surface_type
    } do
      assert_error(rename_surface_type, {:error, :surface_type_doesnt_exist})
    end

    test "should not return any events if name is the same as previous one", %{
      add_surface_type: add_surface_type,
      rename_surface_type: rename_surface_type
    } do
      surface_type_added = SurfaceTypeAdded.new(add_surface_type)
      rename_surface_type = %{rename_surface_type | name: surface_type_added.name}
      assert_events([surface_type_added], rename_surface_type, [])
    end
  end
end
