defmodule Club.Brands do
  @moduledoc """
  Brands domain public API
  """

  alias Club.Commanded

  alias Club.ReadRepo, as: Repo

  alias Club.Brands.Commands.{
    AddBrand,
    RenameBrand,
    UpdateBrandUrl
  }

  alias Club.Brands.Queries.BrandNameUnique

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

  def update_brand_url(update_brand_url, metadata)
      when (is_map(update_brand_url) or is_list(update_brand_url)) and
             (is_map(metadata) or is_list(metadata)) do
    cmd = UpdateBrandUrl.new(update_brand_url)

    Commanded.validate_and_dispatch(cmd, metadata: metadata)
  end

  def brand_name_unique?(brand_name) do
    case Repo.one(BrandNameUnique.new(brand_name)) do
      nil -> false
      _ -> true
    end
  end
end
