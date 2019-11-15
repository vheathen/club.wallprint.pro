defmodule Club.Devices do
  @moduledoc """
  Public API for the Devices boundary
  """

  alias Club.Commanded

  alias Club.Devices.Commands.{
    AddDevice
  }

  @spec add_device(device :: map(), metadata :: maybe_improper_list | map) ::
          {:ok, Ecto.UUID.t()} | {:error, any}
  def add_device(device, metadata)
      when (is_map(device) or is_list(device)) and
             (is_map(metadata) or is_list(metadata)) do
    device_uuid = device |> Enum.into(%{}) |> Map.get(:device_uuid, UUID.uuid4())

    cmd =
      device
      |> Map.put(:device_uuid, device_uuid)
      |> AddDevice.new()

    case Commanded.validate_and_dispatch(cmd, metadata: metadata) do
      :ok ->
        {:ok, device_uuid}

      reply ->
        reply
    end
  end
end
