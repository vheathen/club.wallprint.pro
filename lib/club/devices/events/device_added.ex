defmodule Club.Devices.Events.DeviceAdded do
  use Commanded.Event,
    version: 1,
    from: Club.Devices.Commands.AddDevice
end
