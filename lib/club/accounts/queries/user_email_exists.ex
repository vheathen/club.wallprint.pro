defmodule Club.Accounts.Queries.UserEmailExists do
  import Ecto.Query

  alias Club.Accounts.Projections.User

  def new(email) do
    from b in User,
      select: true,
      where: fragment("lower(?) = lower(?)", b.email, ^email),
      limit: 1
  end
end
