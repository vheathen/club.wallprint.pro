defmodule Club.Brands.Queries.BrandNameExists do
  import Ecto.Query

  alias Club.Brands.Projections.Brand

  def new(name) do
    from b in Brand,
      select: true,
      where: fragment("lower(?) = lower(?)", b.name, ^name),
      limit: 1
  end
end
