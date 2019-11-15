defmodule Club.Devices.Aggregates.Device do
  @derive Jason.Encoder

  defstruct uuid: nil,
            model: nil,
            sku: nil,
            url: nil,
            description: nil,
            brand_uuid: nil,
            product_count: 0

  alias Club.Devices.Aggregates.Device

  alias Club.Devices.Commands.{
    AddDevice
  }

  alias Club.Devices.Events.{
    DeviceAdded
  }

  def execute(%Device{uuid: nil}, %AddDevice{} = cmd), do: DeviceAdded.new(cmd)

  def execute(%Device{}, %AddDevice{}), do: {:error, :device_already_exists}

  # state mutators

  def apply(%Device{} = device, %DeviceAdded{} = event) do
    %Device{
      device
      | uuid: event.device_uuid,
        model: event.model,
        sku: event.sku,
        url: event.url,
        description: event.description,
        brand_uuid: event.brand_uuid
    }
  end
end
