defmodule Club.Colors.Aggregates.ColorTest do
  use Club.AggregateCase,
    aggregate: Club.Colors.Aggregates.Color

  alias Club.Colors.Events.{
    ColorAdded,
    ColorRenamed,
    ColorHexUpdated,
    ColorUsed,
    ColorUsageStopped,
    ColorDeleted
  }

  setup do
    add_color = add_color_cmd()

    color_aggregate =
      color_agg(%{
        uuid: add_color.color_uuid,
        name: add_color.name,
        hex: add_color.hex
      })

    [add_color: add_color, color: color_aggregate]
  end

  describe "AddColor command" do
    @describetag :unit

    test "should return ColorAdded event for the first time", %{add_color: cmd, color: color} do
      color_added = ColorAdded.new(cmd)
      assert_events(cmd, [color_added])
      assert_state(cmd, color)
    end

    test "should return {:error, :color_already_exists} on the second try", %{add_color: cmd} do
      color_added = ColorAdded.new(cmd)
      assert_error([color_added], cmd, {:error, :color_already_exists})
    end
  end

  describe "RenameColor command" do
    @describetag :unit

    setup %{add_color: add_color, color: color} do
      rename_color = rename_color_cmd(color_uuid: add_color.color_uuid)

      color = %{color | name: rename_color.name}

      [add_color: add_color, rename_color: rename_color, color: color]
    end

    test "should return ColorRenamed event for the existing color", %{
      add_color: add_color,
      rename_color: rename_color,
      color: color
    } do
      color_added = ColorAdded.new(add_color)
      color_renamed = ColorRenamed.new(rename_color)
      assert_events([color_added], rename_color, [color_renamed])
      assert_state([color_added], rename_color, color)
    end

    test "should return {:error, :color_doesnt_exist} if no such color exists", %{
      rename_color: rename_color
    } do
      assert_error(rename_color, {:error, :color_doesnt_exist})
    end

    test "should not return any events if name is the same as previous one", %{
      add_color: add_color,
      rename_color: rename_color
    } do
      color_added = ColorAdded.new(add_color)
      rename_color = %{rename_color | name: color_added.name}
      assert_events([color_added], rename_color, [])
    end
  end

  describe "UpdateColorHex command" do
    @describetag :unit

    setup %{add_color: add_color, color: color} do
      update_hex = update_color_hex_cmd(color_uuid: add_color.color_uuid)

      color = %{color | hex: update_hex.hex}

      [add_color: add_color, update_hex: update_hex, color: color]
    end

    test "should return ColorHexChanged event for the existing color", %{
      add_color: add_color,
      update_hex: update_hex,
      color: color
    } do
      color_added = ColorAdded.new(add_color)
      hex_updated = ColorHexUpdated.new(update_hex)
      assert_events([color_added], update_hex, [hex_updated])
      assert_state([color_added], update_hex, color)
    end

    test "should return {:error, :color_doesnt_exist} if no such color exists", %{
      update_hex: update_hex
    } do
      assert_error(update_hex, {:error, :color_doesnt_exist})
    end

    test "should not return any events if hex is the same as previous one", %{
      add_color: add_color,
      update_hex: update_hex
    } do
      color_added = ColorAdded.new(add_color)
      update_hex = %{update_hex | hex: color_added.hex}
      assert_events([color_added], update_hex, [])
    end
  end

  describe "UseColor command" do
    @describetag :unit

    setup %{add_color: add_color} do
      use_color = use_color_cmd(color_uuid: add_color.color_uuid)

      [add_color: add_color, use_color: use_color]
    end

    test "should return ColorUsed event for the existing color and unseen thing_uuid",
         %{
           add_color: add_color,
           use_color: use_color1,
           color: color
         } do
      color_added = ColorAdded.new(add_color)

      thing1_used = ColorUsed.new(use_color1)
      color1 = %{color | thing_count: 1, things: [use_color1.thing_uuid]}

      assert_events([color_added], use_color1, [thing1_used])
      assert_state([color_added], use_color1, color1)

      use_color2 = use_color_cmd(color_uuid: add_color.color_uuid)
      thing2_used = ColorUsed.new(use_color2)

      color2 = %{
        color
        | thing_count: 2,
          things: [use_color2.thing_uuid, use_color1.thing_uuid]
      }

      assert_events([color_added, thing1_used], use_color2, [thing2_used])
      assert_state([color_added, thing1_used], use_color2, color2)
    end

    test "should return {:error, :color_doesnt_exist} if no such color exists", %{
      use_color: use_color
    } do
      assert_error(use_color, {:error, :color_doesnt_exist})
    end

    test "should not return any events if thing_uuid has already been used", %{
      add_color: add_color,
      use_color: use_color
    } do
      color_added = ColorAdded.new(add_color)
      thing_used = ColorUsed.new(use_color)
      assert_events([color_added, thing_used], use_color, [])
    end
  end

  describe "StopUsingColor command" do
    @describetag :unit

    setup %{add_color: add_color, color: color} do
      color_added = ColorAdded.new(add_color)

      use_color1 = use_color_cmd(color_uuid: add_color.color_uuid)
      thing1_used = ColorUsed.new(use_color1)

      use_color2 = use_color_cmd(color_uuid: add_color.color_uuid)
      thing2_used = ColorUsed.new(use_color2)

      color2 = %{
        color
        | thing_count: 2,
          things: [use_color2.thing_uuid, use_color1.thing_uuid]
      }

      [
        start_events: [color_added, thing1_used, thing2_used],
        start_state: color2,
        p1: thing1_used,
        p2: thing2_used
      ]
    end

    test "should return ColorUsed event for the existing color and unseen thing_uuid",
         %{
           start_events: start_events,
           start_state: %{uuid: color_uuid} = start_state,
           p1: %{thing_uuid: p1uuid},
           p2: %{thing_uuid: p2uuid}
         } do
      stop_using_color1 = stop_using_color_cmd(color_uuid: color_uuid, thing_uuid: p1uuid)
      thing1_usage_stopped = ColorUsageStopped.new(stop_using_color1)

      assert_events(start_events, stop_using_color1, [thing1_usage_stopped])

      assert_state(start_events, stop_using_color1, %{
        start_state
        | thing_count: 1,
          things: start_state.things -- [p1uuid]
      })

      stop_using_color2 = stop_using_color_cmd(color_uuid: color_uuid, thing_uuid: p2uuid)
      thing2_usage_stopped = ColorUsageStopped.new(stop_using_color2)

      assert_events(start_events ++ [thing1_usage_stopped], stop_using_color2, [
        thing2_usage_stopped
      ])

      assert_state(start_events ++ [thing1_usage_stopped], stop_using_color2, %{
        start_state
        | thing_count: 0,
          things: []
      })
    end

    test "should return {:error, :color_doesnt_exist} if no such color exists" do
      stop_using_color = stop_using_color_cmd()
      assert_error(stop_using_color, {:error, :color_doesnt_exist})
    end

    test "should not return any events if thing_uuid has not been used", %{
      start_events: start_events,
      start_state: %{uuid: color_uuid}
    } do
      stop_using_color = stop_using_color_cmd(color_uuid: color_uuid)
      assert_events(start_events, stop_using_color, [])
    end
  end

  describe "DeleteColor command" do
    @describetag :unit

    setup %{add_color: add_color, color: color} do
      color_added = ColorAdded.new(add_color)

      use_color1 = use_color_cmd(color_uuid: add_color.color_uuid)
      thing1_used = ColorUsed.new(use_color1)

      stop_using_color1 =
        stop_using_color_cmd(
          color_uuid: add_color.color_uuid,
          thing_uuid: use_color1.thing_uuid
        )

      thing1_usage_stopped = ColorUsageStopped.new(stop_using_color1)

      start_state = %{
        color
        | thing_count: 1,
          things: [use_color1.thing_uuid]
      }

      delete_color = delete_color_cmd(color_uuid: start_state.uuid)
      color_deleted = ColorDeleted.new(delete_color)

      [
        start_events: [color_added, thing1_used],
        start_state: start_state,
        thing_unused: thing1_usage_stopped,
        delete_color: delete_color,
        color_deleted: color_deleted
      ]
    end

    test "should return ColorDeleted event for the existing color and thing_count = 0",
         %{
           start_events: start_events,
           start_state: start_state,
           thing_unused: thing1_usage_stopped,
           delete_color: delete_color,
           color_deleted: color_deleted
         } do
      assert_events(start_events ++ [thing1_usage_stopped], delete_color, [color_deleted])

      assert_state(start_events ++ [thing1_usage_stopped], delete_color, %{
        start_state
        | thing_count: 0,
          things: [],
          deleted?: true
      })
    end

    test "should return {:error, :color_doesnt_exist} if no such color exists" do
      delete_color = delete_color_cmd()
      assert_error(delete_color, {:error, :color_doesnt_exist})
    end

    test "should return {:error, :color_used} if color has used", %{
      start_events: start_events,
      delete_color: delete_color
    } do
      assert_error(start_events, delete_color, {:error, :color_used})
    end

    test "should not return any events if color already deleted", %{
      start_events: start_events,
      thing_unused: thing1_usage_stopped,
      delete_color: delete_color,
      color_deleted: color_deleted
    } do
      assert_events(start_events ++ [thing1_usage_stopped, color_deleted], delete_color, [])
    end
  end
end
