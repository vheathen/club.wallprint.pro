defmodule Club.Fixtures.Accounts do
  alias Club.Accounts.Commands.{
    RegisterUser
  }

  defmacro __using__(_opts) do
    quote do
      def register_user_cmd(attrs \\ []),
        do:
          make_cmd(
            :new_user,
            RegisterUser,
            attrs
          )
    end
  end
end
