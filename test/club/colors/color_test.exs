defmodule Club.ColorsTest do
  use Club.DataCase

  alias Commanded.Aggregates.Aggregate

  alias Club.Commanded

  alias Club.Colors
  alias Club.Colors.Aggregates.Color

  alias Club.Colors.Events.{
    ColorAdded,
    ColorRenamed,
    ColorHexUpdated,
    ColorDeleted
  }

  describe "add_color/2" do
    @describetag :integration
    test "should succeed and return a new color_uuid if parameters are correct but doesn't contain color_uuid" do
      color = :new_color |> build() |> Map.delete(:color_uuid)
      {:ok, color_uuid} = Colors.add_color(color, meta())

      assert_receive_event(Commanded, ColorAdded, fn event ->
        assert color_uuid == event.color_uuid
        assert color.name == event.name
        assert color.hex == event.hex
      end)

      assert Aggregate.aggregate_state(Commanded, Color, "color-" <> color_uuid) ==
               %Color{
                 uuid: color_uuid,
                 name: color.name,
                 hex: color.hex
               }
    end

    test "should succeed and return provided color_uuid if parameters are correct" do
      color = :new_color |> build()
      {:ok, color_uuid} = Colors.add_color(color, meta())

      assert color_uuid == color.color_uuid
    end

    test "should fail and return error if parameters are incorrect" do
      color =
        :new_color
        |> build()
        |> Map.delete(:color_uuid)
        |> Map.delete(:name)

      {:error, {:validation_failure, %{name: _}}} = Colors.add_color(color, meta())
    end

    test "should fail and return error if no user_uuid and user_name in metadata" do
      color = :new_color |> build()
      meta = %{}

      assert Colors.add_color(color, meta) ==
               {:error, :validation_failure,
                [
                  {:user_name, "must be provided"},
                  {:user_uuid, "must be provided"}
                ]}
    end
  end

  describe "rename_color/2" do
    @describetag :integration

    test "should succeed and return :ok if parameters are correct" do
      add_color = :new_color |> build()
      {:ok, color_uuid} = Colors.add_color(add_color, meta())

      wait_for_event(Commanded, ColorAdded)

      rename_color = build(:rename_color, color_uuid: color_uuid)
      :ok = Colors.rename_color(rename_color, meta())

      assert_receive_event(Commanded, ColorRenamed, fn event ->
        assert color_uuid == event.color_uuid
        assert rename_color.name == event.name
      end)

      assert Aggregate.aggregate_state(Commanded, Color, "color-" <> color_uuid) ==
               %Color{
                 uuid: color_uuid,
                 name: rename_color.name,
                 hex: add_color.hex
               }
    end

    test "should fail and return error if parameters are incorrect" do
      rename_color =
        :rename_color
        |> build()
        |> Map.delete(:color_uuid)

      assert {:error, {:validation_failure, %{color_uuid: ["can't be blank"]}}} ==
               Colors.rename_color(rename_color, meta())
    end

    test "should fail and return error if no color with this id exists" do
      add_color = build(:new_color)
      {:ok, _color_uuid} = Colors.add_color(add_color, meta())

      wait_for_event(Commanded, ColorAdded)

      rename_color = build(:rename_color)

      assert {:error, :color_doesnt_exist} == Colors.rename_color(rename_color, meta())
    end

    test "should fail and return error color with this id has been deleted" do
      add_color = build(:new_color)
      {:ok, color_uuid} = Colors.add_color(add_color, meta())

      wait_for_event(Commanded, ColorAdded)

      delete_color = build(:delete_color, color_uuid: color_uuid)
      :ok = Colors.delete_color(delete_color, meta())

      wait_for_event(Commanded, ColorDeleted)

      rename_color = build(:rename_color, color_uuid: color_uuid)

      assert {:error, :color_has_been_deleted} == Colors.rename_color(rename_color, meta())
    end

    test "should fail and return error if no user_uuid and user_name in metadata" do
      rename_color = build(:rename_color)
      meta = %{}

      assert Colors.rename_color(rename_color, meta) ==
               {:error, :validation_failure,
                [
                  {:user_name, "must be provided"},
                  {:user_uuid, "must be provided"}
                ]}
    end
  end

  describe "update_color_hex/2" do
    @describetag :integration

    test "should succeed and return :ok if parameters are correct" do
      add_color = :new_color |> build()
      {:ok, color_uuid} = Colors.add_color(add_color, meta())

      wait_for_event(Commanded, ColorAdded)

      update_color_hex = build(:update_color_hex, color_uuid: color_uuid)
      :ok = Colors.update_color_hex(update_color_hex, meta())

      assert_receive_event(Commanded, ColorHexUpdated, fn event ->
        assert color_uuid == event.color_uuid
        assert update_color_hex.hex == event.hex
      end)

      assert Aggregate.aggregate_state(Commanded, Color, "color-" <> color_uuid) ==
               %Color{
                 uuid: color_uuid,
                 name: add_color.name,
                 hex: update_color_hex.hex
               }
    end

    test "should fail and return error if parameters are incorrect" do
      update_color_hex =
        :update_color_hex
        |> build()
        |> Map.delete(:color_uuid)

      assert {:error, {:validation_failure, %{color_uuid: ["can't be blank"]}}} ==
               Colors.update_color_hex(update_color_hex, meta())
    end

    test "should fail and return error if no color with this id exists" do
      add_color = build(:new_color)
      {:ok, _color_uuid} = Colors.add_color(add_color, meta())

      wait_for_event(Commanded, ColorAdded)

      update_color_hex = build(:update_color_hex)

      assert {:error, :color_doesnt_exist} == Colors.update_color_hex(update_color_hex, meta())
    end

    test "should fail and return error color with this id has been deleted" do
      add_color = build(:new_color)
      {:ok, color_uuid} = Colors.add_color(add_color, meta())

      wait_for_event(Commanded, ColorAdded)

      delete_color = build(:delete_color, color_uuid: color_uuid)
      :ok = Colors.delete_color(delete_color, meta())

      wait_for_event(Commanded, ColorDeleted)

      update_color_hex = build(:update_color_hex, color_uuid: color_uuid)

      assert {:error, :color_has_been_deleted} ==
               Colors.update_color_hex(update_color_hex, meta())
    end

    test "should fail and return error if no user_uuid and user_name in metadata" do
      update_color_hex = build(:update_color_hex)
      meta = %{}

      assert Colors.update_color_hex(update_color_hex, meta) ==
               {:error, :validation_failure,
                [
                  {:user_name, "must be provided"},
                  {:user_uuid, "must be provided"}
                ]}
    end
  end

  describe "delete_color/2" do
    @describetag :integration

    test "should succeed and return :ok if parameters are correct" do
      add_color = :new_color |> build()
      {:ok, color_uuid} = Colors.add_color(add_color, meta())

      wait_for_event(Commanded, ColorAdded)

      delete_color = build(:delete_color, color_uuid: color_uuid)
      :ok = Colors.delete_color(delete_color, meta())

      assert_receive_event(Commanded, ColorDeleted, fn event ->
        assert color_uuid == event.color_uuid
      end)

      assert Aggregate.aggregate_state(Commanded, Color, "color-" <> color_uuid) ==
               %Color{
                 uuid: color_uuid,
                 name: add_color.name,
                 hex: add_color.hex,
                 deleted?: true
               }
    end

    test "should fail and return error if parameters are incorrect" do
      delete_color =
        :delete_color
        |> build()
        |> Map.delete(:color_uuid)

      assert {:error, {:validation_failure, %{color_uuid: ["can't be blank"]}}} ==
               Colors.delete_color(delete_color, meta())
    end

    test "should fail and return error if no color with this id exists" do
      add_color = build(:new_color)
      {:ok, _color_uuid} = Colors.add_color(add_color, meta())

      wait_for_event(Commanded, ColorAdded)

      delete_color = build(:delete_color)

      assert {:error, :color_doesnt_exist} == Colors.delete_color(delete_color, meta())
    end

    test "should fail and return error if no user_uuid and user_name in metadata" do
      delete_color = build(:delete_color)
      meta = %{}

      assert {:error, :validation_failure,
              [
                {:user_name, "must be provided"},
                {:user_uuid, "must be provided"}
              ]} == Colors.delete_color(delete_color, meta)
    end
  end
end
