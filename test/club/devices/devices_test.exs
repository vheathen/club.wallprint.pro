defmodule Club.DevicesTest do
  use Club.DataCase

  alias Commanded.Aggregates.Aggregate

  alias Club.Commanded

  alias Club.Devices
  alias Club.Devices.Aggregates.Device

  alias Club.Devices.Events.{
    DeviceAdded
  }

  describe "add_device/2" do
    @describetag :integration
    test "should succeed and return a new device_uuid if parameters are correct but doesn't contain device_uuid" do
      device = :new_device |> build() |> Map.delete(:device_uuid)
      {:ok, device_uuid} = Devices.add_device(device, meta())

      assert_receive_event(Club.Commanded, DeviceAdded, fn event ->
        assert device_uuid == event.device_uuid
        assert device.model == event.model
        assert device.sku == event.sku
        assert device.url == event.url
        assert device.description == event.description
        assert device.brand_uuid == event.brand_uuid
      end)

      assert Aggregate.aggregate_state(Commanded, Device, "device-" <> device_uuid) ==
               %Device{
                 uuid: device_uuid,
                 model: device.model,
                 sku: device.sku,
                 url: device.url,
                 description: device.description,
                 brand_uuid: device.brand_uuid,
                 product_count: 0
               }
    end

    test "should succeed and return provided device_uuid if parameters are correct" do
      device = :new_device |> build()
      {:ok, device_uuid} = Devices.add_device(device, meta())

      assert device_uuid == device.device_uuid
    end

    test "should fail and return error if parameters are incorrect" do
      device =
        :new_device
        |> build()
        |> Map.delete(:device_uuid)
        |> Map.delete(:model)

      {result, {:validation_failure, %{model: _}}} = Devices.add_device(device, meta())
      assert result == :error
    end

    test "should fail and return error if no user_uuid and user_name in metadata" do
      device = :new_device |> build()
      meta = %{}

      assert Devices.add_device(device, meta) ==
               {:error, :validation_failure,
                [
                  {:user_name, "must be provided"},
                  {:user_uuid, "must be provided"}
                ]}
    end
  end
end
