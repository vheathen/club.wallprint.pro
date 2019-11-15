defmodule Club.Devices.Router do
  use Club.Support.Router

  alias Club.Devices.Aggregates.Device

  alias Club.Devices.Commands.{
    AddDevice
  }

  identify(Device, by: :device_uuid, prefix: "device-")

  dispatch(
    [
      AddDevice
    ],
    to: Device
  )
end
