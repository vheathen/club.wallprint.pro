defmodule Club.Accounts.Events.UserRegistered do
  use Commanded.Event,
    version: 1,
    from: Club.Accounts.Commands.RegisterUser
end
