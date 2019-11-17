defmodule Club.SurfaceTypes.Projectors.SurfaceTypeTest do
  use Club.DataCase

  alias Club.ReadRepo, as: Repo

  alias Club.SurfaceTypes

  alias Club.SurfaceTypes.Projections.SurfaceType, as: SurfaceTypeProjection

  alias Club.SurfaceTypes.Events.{
    SurfaceTypeAdded,
    SurfaceTypeRenamed,
    SurfaceTypeSupportToProductAdded,
    SurfaceTypeSupportFromProductWithdrawn
  }

  @topic "domain:surface_types"

  setup do
    Phoenix.PubSub.subscribe(Club.EventBus, @topic)

    surface_type = build(:new_surface_type)

    {:ok, _} = SurfaceTypes.add_surface_type(surface_type, meta())

    wait_for_event(Club.Commanded, SurfaceTypeAdded)

    [surface_type: surface_type]
  end

  describe "SurfaceTypes.Projectors.SurfaceType" do
    @describetag :integration

    test "SurfaceTypeAdded event shoud insert a new surface_type record", %{
      surface_type: %{surface_type_uuid: surface_type_uuid, name: name} = surface_type
    } do
      assert_receive {:surface_type_added,
                      %{
                        surface_type_uuid: ^surface_type_uuid,
                        name: ^name
                      }},
                     1_000

      result = Repo.all(SurfaceTypeProjection)
      assert length(result) == 1
      [surface_type_projection] = result

      assert surface_type.surface_type_uuid == surface_type_projection.surface_type_uuid
      assert surface_type.name == surface_type_projection.name
      assert 0 == surface_type_projection.product_count
    end

    test "SurfaceTypeRenamed event shoud update an existing surface_type record", %{
      surface_type: %{surface_type_uuid: surface_type_uuid} = surface_type
    } do
      %{name: name} =
        rename_surface_type = build(:rename_surface_type, surface_type_uuid: surface_type_uuid)

      :ok = SurfaceTypes.rename_surface_type(rename_surface_type, meta())

      wait_for_event(Club.Commanded, SurfaceTypeRenamed)

      assert_receive {:surface_type_renamed,
                      %{surface_type_uuid: ^surface_type_uuid, name: ^name}},
                     1_000

      result = Repo.all(SurfaceTypeProjection)
      assert length(result) == 1
      [surface_type_projection] = result

      assert surface_type.surface_type_uuid == surface_type_projection.surface_type_uuid
      assert rename_surface_type.name == surface_type_projection.name
      assert 0 == surface_type_projection.product_count
    end

    test "AddSurfaceTypeSupportToProduct event shoud increment product_count of the surface_type record",
         %{
           surface_type: %{surface_type_uuid: surface_type_uuid} = surface_type
         } do
      add_support = add_surface_type_support_cmd(surface_type_uuid: surface_type_uuid)

      :ok = Club.Commanded.dispatch(add_support, metadata: meta())

      wait_for_event(Club.Commanded, SurfaceTypeSupportToProductAdded)

      assert_receive {:support_added, %{surface_type_uuid: ^surface_type_uuid}},
                     1_000

      result = Repo.all(SurfaceTypeProjection)
      assert length(result) == 1
      [surface_type_projection] = result

      assert surface_type.surface_type_uuid == surface_type_projection.surface_type_uuid
      assert surface_type.name == surface_type_projection.name
      assert 1 == surface_type_projection.product_count
    end

    test "WithdrawSurfaceTypeSupportFromProduct event shoud decrement product_count of the surface_type record",
         %{
           surface_type: %{surface_type_uuid: surface_type_uuid} = surface_type
         } do
      add_support1 = add_surface_type_support_cmd(surface_type_uuid: surface_type_uuid)
      add_support2 = add_surface_type_support_cmd(surface_type_uuid: surface_type_uuid)

      :ok = Club.Commanded.dispatch(add_support1, metadata: meta())
      wait_for_event(Club.Commanded, SurfaceTypeSupportToProductAdded)

      assert_receive {:support_added, %{surface_type_uuid: ^surface_type_uuid}},
                     1_000

      :ok = Club.Commanded.dispatch(add_support2, metadata: meta())
      wait_for_event(Club.Commanded, SurfaceTypeSupportToProductAdded)

      assert_receive {:support_added, %{surface_type_uuid: ^surface_type_uuid}},
                     1_000

      withdraw_support =
        withdraw_surface_type_support_cmd(
          surface_type_uuid: surface_type_uuid,
          product_uuid: add_support1.product_uuid
        )

      :ok = Club.Commanded.dispatch(withdraw_support, metadata: meta())
      wait_for_event(Club.Commanded, SurfaceTypeSupportFromProductWithdrawn)

      assert_receive {:support_withdrawn, %{surface_type_uuid: ^surface_type_uuid}},
                     1_000

      result = Repo.all(SurfaceTypeProjection)
      assert length(result) == 1
      [surface_type_projection] = result

      assert surface_type.surface_type_uuid == surface_type_projection.surface_type_uuid
      assert surface_type.name == surface_type_projection.name
      assert 1 == surface_type_projection.product_count
    end
  end
end
