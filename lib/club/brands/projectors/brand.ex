defmodule Club.Brands.Projectors.Brand do
  use Commanded.Projections.Ecto,
    application: Club.Commanded,
    repo: Club.ReadRepo,
    name: "brands_brand",
    consistency: Application.get_env(:my_app, :consistency, :eventual)

  alias Club.Brands.Projections.Brand

  alias Club.Brands.Events.{
    BrandAdded,
    BrandRenamed,
    BrandUrlUpdated
  }

  project(%BrandAdded{} = brand_added, _meta, fn multi ->
    Ecto.Multi.insert(
      multi,
      :brand,
      %Brand{
        brand_uuid: brand_added.brand_uuid,
        brand_name: brand_added.brand_name,
        brand_url: brand_added.brand_url,
        product_count: 0
      }
    )
  end)

  def after_update(%BrandAdded{brand_uuid: brand_uuid}, _metadata, _changes) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      "domain:brands",
      {:brand_added, %{brand_uuid: brand_uuid}}
    )

    :ok
  end

  project(
    %BrandRenamed{brand_uuid: brand_uuid, brand_name: brand_name},
    _meta,
    fn multi ->
      update_brand(multi, brand_uuid, brand_name: brand_name)
    end
  )

  def after_update(
        %BrandRenamed{brand_uuid: brand_uuid, brand_name: brand_name},
        _metadata,
        _changes
      ) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      "domain:brands",
      {:brand_renamed, %{brand_uuid: brand_uuid, brand_name: brand_name}}
    )

    :ok
  end

  project(
    %BrandUrlUpdated{brand_uuid: brand_uuid, brand_url: brand_url},
    _meta,
    fn multi ->
      update_brand(multi, brand_uuid, brand_url: brand_url)
    end
  )

  def after_update(
        %BrandUrlUpdated{brand_uuid: brand_uuid, brand_url: brand_url},
        _metadata,
        _changes
      ) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      "domain:brands",
      {:brand_url_updated, %{brand_uuid: brand_uuid, brand_url: brand_url}}
    )

    :ok
  end

  defp update_brand(multi, brand_uuid, changes) do
    Ecto.Multi.update_all(multi, :brand, brand_query(brand_uuid), set: changes)
  end

  defp brand_query(brand_uuid) do
    from b in Brand, where: b.brand_uuid == ^brand_uuid
  end
end
