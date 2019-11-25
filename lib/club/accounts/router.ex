defmodule Club.Accounts.Router do
  use Club.Support.Router

  alias Club.Accounts.Aggregates.User

  alias Club.Accounts.Commands.{
    RegisterUser
  }

  identify(User, by: :user_uuid, prefix: "user-")

  dispatch(
    [
      RegisterUser
    ],
    to: User
  )
end
