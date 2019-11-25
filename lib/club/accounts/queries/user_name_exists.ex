defmodule Club.Accounts.Queries.UserNameExists do
  import Ecto.Query

  alias Club.Accounts.Projections.User

  def new(name) do
    from b in User,
      select: true,
      where: fragment("lower(?) = lower(?)", b.name, ^name),
      limit: 1
  end
end
