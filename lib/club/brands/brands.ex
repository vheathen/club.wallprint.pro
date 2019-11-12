defmodule Club.Brands do
  @moduledoc """
  Brands domain public API
  """

  alias Club.Commanded
  alias Club.Brands.Commands.AddBrand

  def add_brand(brand, metadata)
      when (is_map(brand) or is_list(brand)) and
             (is_map(metadata) or is_list(metadata)) do
    brand_uuid = brand |> Enum.into(%{}) |> Map.get(:brand_uuid, UUID.uuid4())

    cmd =
      brand
      |> Map.put(:brand_uuid, brand_uuid)
      |> AddBrand.new()

    with :ok <- Commanded.validate_and_dispatch(cmd, metadata: metadata) do
      {:ok, brand_uuid}
    else
      reply -> reply
    end
  end
end
