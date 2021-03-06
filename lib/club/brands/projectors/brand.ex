defmodule Club.Brands.Projectors.Brand do
  use Commanded.Projections.Ecto,
    application: Club.Commanded,
    repo: Club.ReadRepo,
    name: "brands_brand",
    consistency: Application.get_env(:my_app, :consistency, :eventual)

  alias Club.Brands.Projections.Brand

  alias Club.Brands.Events.{
    BrandAdded,
    BrandDeleted,
    BrandRenamed,
    BrandUrlUpdated,
    NewProductWithBrandLinked,
    ProductFromBrandUnlinked
  }

  @topic "domain:brands"

  project(%BrandAdded{} = brand_added, _meta, fn multi ->
    Ecto.Multi.insert(
      multi,
      :brand,
      %Brand{
        brand_uuid: brand_added.brand_uuid,
        name: brand_added.name,
        url: brand_added.url,
        product_count: 0
      }
    )
  end)

  def after_update(%BrandAdded{brand_uuid: brand_uuid}, _metadata, _changes) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      @topic,
      {:brand_added, %{brand_uuid: brand_uuid}}
    )

    :ok
  end

  project(%BrandDeleted{brand_uuid: brand_uuid}, _meta, fn multi ->
    Ecto.Multi.delete_all(
      multi,
      :brand,
      brand_query(brand_uuid)
    )
  end)

  def after_update(%BrandDeleted{brand_uuid: brand_uuid}, _metadata, _changes) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      @topic,
      {:brand_deleted, %{brand_uuid: brand_uuid}}
    )

    :ok
  end

  project(
    %BrandRenamed{brand_uuid: brand_uuid, name: name},
    _meta,
    fn multi ->
      update_brand(multi, brand_uuid, set: [name: name])
    end
  )

  def after_update(
        %BrandRenamed{brand_uuid: brand_uuid, name: name},
        _metadata,
        _changes
      ) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      @topic,
      {:brand_renamed, %{brand_uuid: brand_uuid, name: name}}
    )

    :ok
  end

  project(
    %BrandUrlUpdated{brand_uuid: brand_uuid, url: url},
    _meta,
    fn multi ->
      update_brand(multi, brand_uuid, set: [url: url])
    end
  )

  def after_update(
        %BrandUrlUpdated{brand_uuid: brand_uuid, url: url},
        _metadata,
        _changes
      ) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      @topic,
      {:url_updated, %{brand_uuid: brand_uuid, url: url}}
    )

    :ok
  end

  project(
    %NewProductWithBrandLinked{brand_uuid: brand_uuid},
    _meta,
    fn multi ->
      update_brand(multi, brand_uuid, inc: [product_count: 1])
    end
  )

  def after_update(
        %NewProductWithBrandLinked{brand_uuid: brand_uuid},
        _metadata,
        _changes
      ) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      @topic,
      {:product_linked, %{brand_uuid: brand_uuid}}
    )

    :ok
  end

  project(
    %ProductFromBrandUnlinked{brand_uuid: brand_uuid},
    _meta,
    fn multi ->
      update_brand(multi, brand_uuid, inc: [product_count: -1])
    end
  )

  def after_update(
        %ProductFromBrandUnlinked{brand_uuid: brand_uuid},
        _metadata,
        _changes
      ) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      @topic,
      {:product_unlinked, %{brand_uuid: brand_uuid}}
    )

    :ok
  end

  defp update_brand(multi, brand_uuid, changes) do
    Ecto.Multi.update_all(multi, :brand, brand_query(brand_uuid), changes)
  end

  defp brand_query(brand_uuid) do
    from b in Brand, where: b.brand_uuid == ^brand_uuid
  end
end
