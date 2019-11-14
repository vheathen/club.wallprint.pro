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

  alias Club.Brands.Queries.BrandNameExists

  @spec add_brand(brand :: map(), metadata :: maybe_improper_list | map) ::
          {:ok, Ecto.UUID.t()} | {:error, any}
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

  @spec rename_brand(rename_brand :: map(), metadata :: maybe_improper_list | map) ::
          :ok | {:error, any}
  def rename_brand(rename_brand, metadata)
      when (is_map(rename_brand) or is_list(rename_brand)) and
             (is_map(metadata) or is_list(metadata)) do
    cmd = RenameBrand.new(rename_brand)

    Commanded.validate_and_dispatch(cmd, metadata: metadata)
  end

  @spec update_brand_url(update_brand_url :: map(), metadata :: maybe_improper_list | map) ::
          :ok | {:error, any}
  def update_brand_url(update_brand_url, metadata)
      when (is_map(update_brand_url) or is_list(update_brand_url)) and
             (is_map(metadata) or is_list(metadata)) do
    cmd = UpdateBrandUrl.new(update_brand_url)

    Commanded.validate_and_dispatch(cmd, metadata: metadata)
  end

  @spec brand_unique?(brand :: map()) :: boolean()
  def brand_unique?(%{brand_name: brand_name}) do
    case Repo.one(BrandNameExists.new(brand_name)) do
      true -> false
      nil -> true
    end
  end

  def brand_unique?(%Ecto.Changeset{} = cmd) do
    cmd
    |> Ecto.Changeset.apply_changes()
    |> brand_unique?()
  end
end
