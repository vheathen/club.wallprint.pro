defmodule Club.SurfaceTypes.Aggregates.SurfaceTypeTest do
  use Club.AggregateCase,
    aggregate: Club.SurfaceTypes.Aggregates.SurfaceType

  alias Club.SurfaceTypes.Commands.{
    AddSurfaceType,
    RenameSurfaceType
  }

  alias Club.SurfaceTypes.Events.{
    SurfaceTypeAdded,
    SurfaceTypeRenamed,
    SurfaceTypeSupportToProductAdded,
    SurfaceTypeSupportFromProductWithdrawn
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

  describe "AddSurfaceTypeSupportToProduct command" do
    @describetag :unit

    setup %{add_surface_type: add_surface_type} do
      add_support =
        add_surface_type_support_cmd(surface_type_uuid: add_surface_type.surface_type_uuid)

      [add_surface_type: add_surface_type, add_support: add_support]
    end

    test "should return SurfaceTypeSupportToProductAdded event for the existing surface_type and unseen product_uuid",
         %{
           add_surface_type: add_surface_type,
           add_support: add_support1,
           surface_type: surface_type
         } do
      surface_type_added = SurfaceTypeAdded.new(add_surface_type)

      support1_added = SurfaceTypeSupportToProductAdded.new(add_support1)
      surface_type1 = %{surface_type | product_count: 1, products: [add_support1.product_uuid]}

      assert_events([surface_type_added], add_support1, [support1_added])
      assert_state([surface_type_added], add_support1, surface_type1)

      add_support2 =
        add_surface_type_support_cmd(surface_type_uuid: add_surface_type.surface_type_uuid)

      support2_added = SurfaceTypeSupportToProductAdded.new(add_support2)

      surface_type2 = %{
        surface_type
        | product_count: 2,
          products: [add_support2.product_uuid, add_support1.product_uuid]
      }

      assert_events([surface_type_added, support1_added], add_support2, [support2_added])
      assert_state([surface_type_added, support1_added], add_support2, surface_type2)
    end

    test "should return {:error, :surface_type_doesnt_exist} if no such surface_type exists", %{
      add_support: add_support
    } do
      assert_error(add_support, {:error, :surface_type_doesnt_exist})
    end

    test "should not return any events if product_uuid has already been linked", %{
      add_surface_type: add_surface_type,
      add_support: add_support
    } do
      surface_type_added = SurfaceTypeAdded.new(add_surface_type)
      support_added = SurfaceTypeSupportToProductAdded.new(add_support)
      assert_events([surface_type_added, support_added], add_support, [])
    end
  end

  describe "WithdrawSurfaceTypeSupportFromProduct command" do
    @describetag :unit

    setup %{add_surface_type: add_surface_type, surface_type: surface_type} do
      surface_type_added = SurfaceTypeAdded.new(add_surface_type)

      add_support1 =
        add_surface_type_support_cmd(surface_type_uuid: add_surface_type.surface_type_uuid)

      support1_added = SurfaceTypeSupportToProductAdded.new(add_support1)

      add_support2 =
        add_surface_type_support_cmd(surface_type_uuid: add_surface_type.surface_type_uuid)

      support2_added = SurfaceTypeSupportToProductAdded.new(add_support2)

      surface_type2 = %{
        surface_type
        | product_count: 2,
          products: [add_support2.product_uuid, add_support1.product_uuid]
      }

      [
        start_events: [surface_type_added, support1_added, support2_added],
        start_state: surface_type2,
        p1: support1_added,
        p2: support2_added
      ]
    end

    test "should return SurfaceTypeSupportFromProductWithdrawn event for the existing surface_type and known product_uuid",
         %{
           start_events: start_events,
           start_state: %{uuid: surface_type_uuid} = start_state,
           p1: %{product_uuid: p1uuid},
           p2: %{product_uuid: p2uuid}
         } do
      withdraw_support1 =
        withdraw_surface_type_support_cmd(
          surface_type_uuid: surface_type_uuid,
          product_uuid: p1uuid
        )

      support1_withdrawn = SurfaceTypeSupportFromProductWithdrawn.new(withdraw_support1)

      assert_events(start_events, withdraw_support1, [support1_withdrawn])

      assert_state(start_events, withdraw_support1, %{
        start_state
        | product_count: 1,
          products: start_state.products -- [p1uuid]
      })

      withdraw_support2 =
        withdraw_surface_type_support_cmd(
          surface_type_uuid: surface_type_uuid,
          product_uuid: p2uuid
        )

      support2_withdrawn = SurfaceTypeSupportFromProductWithdrawn.new(withdraw_support2)

      assert_events(start_events ++ [support1_withdrawn], withdraw_support2, [support2_withdrawn])

      assert_state(start_events ++ [support1_withdrawn], withdraw_support2, %{
        start_state
        | product_count: 0,
          products: []
      })
    end

    test "should return {:error, :surface_type_doesnt_exist} if no such surface_type exists" do
      withdraw_support = withdraw_surface_type_support_cmd()
      assert_error(withdraw_support, {:error, :surface_type_doesnt_exist})
    end

    test "should not return any events if product_uuid has not been linked", %{
      start_events: start_events,
      start_state: %{uuid: surface_type_uuid}
    } do
      withdraw_support = withdraw_surface_type_support_cmd(surface_type_uuid: surface_type_uuid)
      assert_events(start_events, withdraw_support, [])
    end
  end
end
