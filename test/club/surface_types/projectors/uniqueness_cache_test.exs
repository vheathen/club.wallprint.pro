defmodule Club.SurfaceTypes.Projectors.UniquenessCacheTest do
  use Club.DataCase

  require Cachex.Spec

  alias Club.SurfaceTypes

  @uniqueness_key Club.Support.Unique
  @cachex_adapter Module.concat(@uniqueness_key, Cachex)

  @topic "domain:surface_types"

  setup_all do
    case Cachex.get(@cachex_adapter, :anything) do
      {:error, :no_cache} ->
        Application.put_env(:club, @uniqueness_key, adapter: @cachex_adapter)

        {:ok, _} =
          Cachex.start_link(@cachex_adapter, expiration: Cachex.Spec.expiration(default: 100))

      {:ok, _} ->
        true
    end

    :ok
  end

  setup do
    on_exit(fn ->
      Cachex.clear(@cachex_adapter)
    end)

    Phoenix.PubSub.subscribe(Club.EventBus, @topic)

    surface_type = build(:new_surface_type)
    {:ok, uuid} = SurfaceTypes.add_surface_type(surface_type, meta())

    assert_receive {:surface_type_added, %{surface_type_uuid: ^uuid}}, 1_000

    [surface_type: surface_type]
  end

  describe "uniqueness cache records should be released" do
    @describetag :integration

    test "on surface_type_deleted event", %{
      surface_type: %{surface_type_uuid: old_uuid, name: old_name} = old_surface_type
    } do
      new_surface_type = build(:new_surface_type, name: old_name)

      delete_surface_type =
        build(:delete_surface_type, surface_type_uuid: old_surface_type.surface_type_uuid)

      assert {:error, :validation_failure, [surface_type: "has already exist"]} ==
               SurfaceTypes.add_surface_type(new_surface_type, meta())

      :ok = SurfaceTypes.delete_surface_type(delete_surface_type, meta())

      assert_receive {:surface_type_deleted, %{surface_type_uuid: ^old_uuid}}, 1_000

      Process.sleep(1_000)

      assert {:ok, _} = SurfaceTypes.add_surface_type(new_surface_type, meta())
    end
  end
end
