defmodule Club.Devices.Commands.AddDeviceTest do
  use Club.CommandCase,
    command: Club.Devices.Commands.AddDevice,
    factory: :new_device

  alias Club.Devices.Commands.AddDevice

  required_fields([
    :device_uuid,
    :model,
    :brand_uuid,
    :brand_name
  ])

  optional_fields([
    :sku,
    :url,
    :description
  ])

  fields(
    :string,
    [
      :model,
      :sku,
      :description
    ]
  )

  fields(
    Ecto.UUID,
    [
      :device_uuid,
      :brand_uuid
    ]
  )

  # fields(
  #   :url,
  #   [
  #     :url
  #   ]
  # )

  basic_command_tests()

  describe "AddDevice" do
    @describetag :unit

    test "incorrect device url - invalid command" do
      ~w(
        htup://wrong_scheme_url.com
        no_scheme_url.com
        just_a_string
      )
      |> Enum.each(fn url ->
        device = build(:new_device, %{url: url})

        %{errors: errors} = cmd = AddDevice.new(device)
        refute cmd.valid?
        assert Enum.any?(errors, fn {field, {_, [validation: :url]}} -> field == :url end)
      end)
    end
  end
end
