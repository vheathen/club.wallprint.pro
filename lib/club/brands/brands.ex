defmodule Club.Brands do
  @moduledoc """
  Brands domain public API
  """

  alias Club.Commanded

  alias Club.Brands.Commands.{
    AddBrand,
    RenameBrand
  }

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

  def rename_brand(rename_brand, metadata)
      when (is_map(rename_brand) or is_list(rename_brand)) and
             (is_map(metadata) or is_list(metadata)) do
    cmd = RenameBrand.new(rename_brand)

    Commanded.validate_and_dispatch(cmd, metadata: metadata)
  end
end
