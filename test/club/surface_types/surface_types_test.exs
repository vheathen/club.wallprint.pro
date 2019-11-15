defmodule Club.SurfaceTypesTest do
  use Club.DataCase

  alias Commanded.Aggregates.Aggregate

  alias Club.Commanded

  alias Club.SurfaceTypes
  alias Club.SurfaceTypes.Aggregates.SurfaceType

  alias Club.SurfaceTypes.Events.{
    SurfaceTypeAdded
  }

  describe "add_surface_type/2" do
    @describetag :integration
    test "should succeed and return a new surface_type_uuid if parameters are correct but doesn't contain surface_type_uuid" do
      surface_type = :new_surface_type |> build() |> Map.delete(:surface_type_uuid)
      {:ok, surface_type_uuid} = SurfaceTypes.add_surface_type(surface_type, meta())

      assert_receive_event(Club.Commanded, SurfaceTypeAdded, fn event ->
        assert surface_type_uuid == event.surface_type_uuid
        assert surface_type.name == event.name
      end)

      assert Aggregate.aggregate_state(
               Commanded,
               SurfaceType,
               "surface_type-" <> surface_type_uuid
             ) ==
               %SurfaceType{
                 uuid: surface_type_uuid,
                 name: surface_type.name,
                 product_count: 0
               }
    end

    test "should succeed and return provided surface_type_uuid if parameters are correct" do
      surface_type = :new_surface_type |> build()
      {:ok, surface_type_uuid} = SurfaceTypes.add_surface_type(surface_type, meta())

      assert surface_type_uuid == surface_type.surface_type_uuid
    end

    test "should fail and return error if parameters are incorrect" do
      surface_type =
        :new_surface_type
        |> build()
        |> Map.delete(:surface_type_uuid)
        |> Map.delete(:name)

      {result, {:validation_failure, %{name: _}}} =
        SurfaceTypes.add_surface_type(surface_type, meta())

      assert result == :error
    end

    test "should fail and return error if no user_uuid and user_name in metadata" do
      surface_type = :new_surface_type |> build()
      meta = %{}

      assert SurfaceTypes.add_surface_type(surface_type, meta) ==
               {:error, :validation_failure,
                [
                  {:user_name, "must be provided"},
                  {:user_uuid, "must be provided"}
                ]}
    end
  end

  describe "surface_type_exists?/1" do
    @describetag :integration

    setup do
      Phoenix.PubSub.subscribe(Club.EventBus, "domain:surface_types")

      %{surface_type_uuid: surface_type_uuid, name: name} =
        surface_type = build(:new_surface_type)

      {:ok, _} = SurfaceTypes.add_surface_type(surface_type, meta())

      assert_receive {:surface_type_added, %{surface_type_uuid: ^surface_type_uuid, name: ^name}},
                     1_000

      [surface_type: surface_type]
    end

    test "should return true if there is no such surface_type", %{
      surface_type: %{name: existing_name}
    } do
      unique_name = unique_name(existing_name)

      assert SurfaceTypes.surface_type_unique?(%{name: unique_name})
    end

    test "should return false if the surface_type exists", %{
      surface_type: surface_type
    } do
      refute SurfaceTypes.surface_type_unique?(surface_type)
    end

    def unique_name(old_name) do
      name = Faker.Company.buzzword()

      case name != old_name do
        true -> name
        false -> unique_name(old_name)
      end
    end
  end
end
