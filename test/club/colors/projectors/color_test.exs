defmodule Club.Colors.Projectors.ColorTest do
  use Club.DataCase

  alias Club.ReadRepo, as: Repo

  alias Club.Colors

  alias Club.Colors.Projections.Color, as: ColorProjection

  alias Club.Colors.Events.{
    ColorAdded,
    ColorRenamed,
    ColorHexUpdated,
    ColorUsed,
    ColorUsageStopped
  }

  @topic "domain:colors"

  setup do
    Phoenix.PubSub.subscribe(Club.EventBus, @topic)

    color = add_color_cmd() |> Map.from_struct()

    {:ok, _} = Colors.add_color(color, meta())

    wait_for_event(Club.Commanded, ColorAdded)

    [color: color]
  end

  describe "Colors.Projectors.Color on" do
    @describetag :integration

    test "ColorAdded event shoud insert a new color record", %{
      color: %{color_uuid: color_uuid} = color
    } do
      assert_receive {:color_added, %{color_uuid: ^color_uuid}}, 1_000

      result = Repo.all(ColorProjection)
      assert length(result) == 1
      [color_projection] = result

      assert color.color_uuid == color_projection.color_uuid
      assert color.name == color_projection.name
      assert color.hex == color_projection.hex
      assert 0 == color_projection.thing_count
    end

    test "ColorRenamed event shoud update an existing color record", %{
      color: %{color_uuid: color_uuid} = color
    } do
      %{name: name} = rename_color = build(:rename_color, color_uuid: color_uuid)

      :ok = Colors.rename_color(rename_color, meta())

      wait_for_event(Club.Commanded, ColorRenamed)

      assert_receive {:color_renamed, %{color_uuid: ^color_uuid, name: ^name}},
                     1_000

      result = Repo.all(ColorProjection)
      assert length(result) == 1
      [color_projection] = result

      assert color.color_uuid == color_projection.color_uuid
      assert rename_color.name == color_projection.name
      assert color.hex == color_projection.hex
      assert 0 == color_projection.thing_count
    end

    test "ColorHexUpdated event shoud update an existing color record", %{
      color: %{color_uuid: color_uuid} = color
    } do
      %{hex: hex} = update_hex = build(:update_color_hex, color_uuid: color_uuid)

      :ok = Colors.update_color_hex(update_hex, meta())

      wait_for_event(Club.Commanded, ColorHexUpdated)

      assert_receive {:hex_updated, %{color_uuid: ^color_uuid, hex: ^hex}},
                     1_000

      result = Repo.all(ColorProjection)
      assert length(result) == 1
      [color_projection] = result

      assert color.color_uuid == color_projection.color_uuid
      assert color.name == color_projection.name
      assert update_hex.hex == color_projection.hex
      assert 0 == color_projection.thing_count
    end

    test "UseColor event shoud increment thing_count of the color record", %{
      color: %{color_uuid: color_uuid} = color
    } do
      use_color = use_color_cmd(color_uuid: color_uuid)

      :ok = Club.Commanded.dispatch(use_color, metadata: meta())

      wait_for_event(Club.Commanded, ColorUsed)

      assert_receive {:color_used, %{color_uuid: ^color_uuid}},
                     1_000

      result = Repo.all(ColorProjection)
      assert length(result) == 1
      [color_projection] = result

      assert color.color_uuid == color_projection.color_uuid
      assert color.name == color_projection.name
      assert color.hex == color_projection.hex
      assert 1 == color_projection.thing_count
    end

    test "StopUsingColor event shoud decrement thing_count of the color record", %{
      color: %{color_uuid: color_uuid} = color
    } do
      use_color1 = use_color_cmd(color_uuid: color_uuid)
      use_color2 = use_color_cmd(color_uuid: color_uuid)

      :ok = Club.Commanded.dispatch(use_color1, metadata: meta())
      wait_for_event(Club.Commanded, ColorUsed)

      assert_receive {:color_used, %{color_uuid: ^color_uuid}},
                     1_000

      :ok = Club.Commanded.dispatch(use_color2, metadata: meta())
      wait_for_event(Club.Commanded, ColorUsed)

      assert_receive {:color_used, %{color_uuid: ^color_uuid}},
                     1_000

      stop_using = stop_using_color_cmd(color_uuid: color_uuid, thing_uuid: use_color1.thing_uuid)

      :ok = Club.Commanded.dispatch(stop_using, metadata: meta())
      wait_for_event(Club.Commanded, ColorUsageStopped)

      assert_receive {:color_usage_stopped, %{color_uuid: ^color_uuid}},
                     1_000

      result = Repo.all(ColorProjection)
      assert length(result) == 1
      [color_projection] = result

      assert color.color_uuid == color_projection.color_uuid
      assert color.name == color_projection.name
      assert color.hex == color_projection.hex
      assert 1 == color_projection.thing_count
    end

    test "ColorDeleted event shoud delete an old color record", %{
      color: %{color_uuid: color_uuid}
    } do
      assert_receive {:color_added, %{color_uuid: ^color_uuid}}, 1_000

      assert [_] = Repo.all(ColorProjection)

      delete_color = delete_color_cmd(color_uuid: color_uuid)
      :ok = Club.Commanded.dispatch(delete_color, metadata: meta())

      assert_receive {:color_deleted, %{color_uuid: ^color_uuid}}, 1_000

      assert [] = Repo.all(ColorProjection)
    end
  end
end
