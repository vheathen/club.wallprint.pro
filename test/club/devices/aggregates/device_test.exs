defmodule Club.Devices.Aggregates.DeviceTest do
  use Club.AggregateCase,
    aggregate: Club.Devices.Aggregates.Device

  alias Club.Devices.Aggregates.Device

  alias Club.Devices.Commands.{
    AddDevice
  }

  alias Club.Devices.Events.{
    DeviceAdded
  }

  setup do
    add_device =
      :new_device
      |> build()
      |> AddDevice.new()
      |> Ecto.Changeset.apply_changes()

    device_aggregate =
      build(:device_aggregate, %{
        uuid: add_device.device_uuid,
        model: add_device.model,
        sku: add_device.sku,
        url: add_device.url,
        description: add_device.description,
        brand_uuid: add_device.brand_uuid,
        product_count: 0
      })

    [add_device: add_device, device: device_aggregate]
  end

  describe "AddDevice command" do
    @describetag :unit

    test "should return DeviceAdded event for the first time", %{add_device: cmd, device: device} do
      device_added = DeviceAdded.new(cmd)
      assert_events(cmd, [device_added])
      assert_state(cmd, device)
    end

    test "should return {:error, :device_already_exists} on the second try", %{add_device: cmd} do
      device_added = DeviceAdded.new(cmd)
      assert_error([device_added], cmd, {:error, :device_already_exists})
    end
  end
end
