defmodule Club.SurfaceTypes.Commands.UniqueSurfaceTypeNameTest do
  use Club.DataCase

  alias Club.ReadRepo, as: Repo
  require Cachex.Spec

  alias Club.SurfaceTypes
  alias Club.SurfaceTypes.Projections.SurfaceType, as: SurfaceTypeProjection

  @topic "domain:surface_types"

  setup do
    on_exit(fn ->
      Cachex.clear(Commanded.Middleware.Uniqueness.Adapter.get())
    end)

    Phoenix.PubSub.subscribe(Club.EventBus, @topic)

    %{surface_type_uuid: uuid} = surface_type = new_surface_type()
    {:ok, _} = SurfaceTypes.add_surface_type(surface_type, meta())

    assert_receive {:surface_type_added, %{surface_type_uuid: ^uuid}}, 1_000

    [surface_type: surface_type]
  end

  describe "AddSurfaceType" do
    @describetag :integration

    test "with unique name should succeed" do
      %{surface_type_uuid: uuid} = surface_type = new_surface_type()
      {:ok, _} = SurfaceTypes.add_surface_type(surface_type, meta())
      assert_receive {:surface_type_added, %{surface_type_uuid: ^uuid}}, 1_000
      assert length(Repo.all(SurfaceTypeProjection)) == 2
    end

    test "with duplicate name should fail based on the cached results", %{
      surface_type: surface_type
    } do
      uuid = UUID.uuid4()
      surface_type = %{surface_type | surface_type_uuid: uuid}
      Repo.delete_all(SurfaceTypeProjection)
      result = SurfaceTypes.add_surface_type(surface_type, meta())
      assert result == {:error, :validation_failure, [surface_type: "has already exist"]}
    end

    test "with duplicate name should fail based on the readstore results", %{
      surface_type: surface_type
    } do
      uuid = UUID.uuid4()
      surface_type = %{surface_type | surface_type_uuid: uuid}
      Cachex.clear(Commanded.Middleware.Uniqueness.Adapter.get())
      result = SurfaceTypes.add_surface_type(surface_type, meta())
      assert result == {:error, :validation_failure, [surface_type: "has already exist"]}
    end
  end

  describe "RenameSurfaceType" do
    @describetag :integration

    test "with unique name should succeed", %{
      surface_type: %{surface_type_uuid: surface_type_uuid}
    } do
      rename_surface_type = rename_surface_type(%{surface_type_uuid: surface_type_uuid})
      :ok = SurfaceTypes.rename_surface_type(rename_surface_type, meta())
      assert_receive {:surface_type_renamed, %{surface_type_uuid: ^surface_type_uuid}}, 1_000
      assert length(Repo.all(SurfaceTypeProjection)) == 1
    end

    test "with duplicate name should fail based on the cached results", %{
      surface_type: surface_type
    } do
      %{surface_type_uuid: new_uuid} = new_surface_type = new_surface_type()
      {:ok, _} = SurfaceTypes.add_surface_type(new_surface_type, meta())

      assert_receive {:surface_type_added, %{surface_type_uuid: ^new_uuid}}, 1_000
      assert length(Repo.all(SurfaceTypeProjection)) == 2

      Repo.delete_all(SurfaceTypeProjection)

      rename_surface_type =
        rename_surface_type(%{surface_type_uuid: new_uuid, name: surface_type.name})

      result = SurfaceTypes.rename_surface_type(rename_surface_type, meta())
      assert result == {:error, :validation_failure, [surface_type: "has already exist"]}
    end

    test "with duplicate name should fail based on the readstore results", %{
      surface_type: surface_type
    } do
      %{surface_type_uuid: new_uuid} = new_surface_type = new_surface_type()
      {:ok, _} = SurfaceTypes.add_surface_type(new_surface_type, meta())

      assert_receive {:surface_type_added, %{surface_type_uuid: ^new_uuid}}, 1_000
      assert length(Repo.all(SurfaceTypeProjection)) == 2

      Cachex.clear(Commanded.Middleware.Uniqueness.Adapter.get())

      rename_surface_type =
        rename_surface_type(%{surface_type_uuid: new_uuid, name: surface_type.name})

      result = SurfaceTypes.rename_surface_type(rename_surface_type, meta())
      assert result == {:error, :validation_failure, [surface_type: "has already exist"]}
    end
  end

  defp new_surface_type(attrs \\ []) do
    build(:new_surface_type, attrs)
  end

  defp rename_surface_type(attrs) do
    build(:rename_surface_type, attrs)
  end
end
