defmodule Club.Brands.Queries.BrandNameUnique do
  import Ecto.Query

  alias Club.Brands.Projections.Brand

  def new(brand_name) do
    from b in Brand,
      select: true,
      where: fragment("lower(?)", b.brand_name) == ^brand_name,
      limit: 1
  end
end
