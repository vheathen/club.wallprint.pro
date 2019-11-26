defmodule Club.Brands do
  @moduledoc """
  Brands domain public API
  """

  alias Club.Commanded

  alias Club.ReadRepo, as: Repo

  alias Club.Brands.Commands.{
    AddBrand,
    RenameBrand,
    UpdateBrandUrl,
    DeleteBrand
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

    case Commanded.validate_and_dispatch(cmd, metadata: metadata) do
      :ok ->
        {:ok, brand_uuid}

      reply ->
        reply
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

  @spec update_url(update_url :: map(), metadata :: maybe_improper_list | map) ::
          :ok | {:error, any}
  def update_url(update_url, metadata)
      when (is_map(update_url) or is_list(update_url)) and
             (is_map(metadata) or is_list(metadata)) do
    cmd = UpdateBrandUrl.new(update_url)

    Commanded.validate_and_dispatch(cmd, metadata: metadata)
  end

  @spec delete_brand(delete_brand :: map(), metadata :: maybe_improper_list | map) ::
          :ok | {:error, any}
  def delete_brand(delete_brand, metadata)
      when (is_map(delete_brand) or is_list(delete_brand)) and
             (is_map(metadata) or is_list(metadata)) do
    cmd = DeleteBrand.new(delete_brand)

    Commanded.validate_and_dispatch(cmd, metadata: metadata)
  end

  @spec brand_unique?(brand :: map()) :: boolean()
  def brand_unique?(%{name: name}) do
    case Repo.one(BrandNameExists.new(name)) do
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
