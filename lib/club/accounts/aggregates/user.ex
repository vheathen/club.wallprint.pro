defmodule Club.Accounts.Aggregates.User do
  @derive Jason.Encoder

  defstruct uuid: nil,
            email: nil,
            name: nil,
            identities: [],
            email_confirmed?: false,
            state: :unverified,
            deleted?: false

  alias Club.Accounts.Aggregates.User

  alias Club.Accounts.Commands.{
    RegisterUser
  }

  alias Club.Accounts.Events.{
    UserRegistered
    # UserDeleted
  }

  # RegisterUser
  def execute(%User{uuid: nil}, %RegisterUser{} = cmd), do: UserRegistered.new(cmd)

  def execute(%User{}, %RegisterUser{}), do: {:error, :user_already_exists}

  # if User doesn't exists we should return error for all but RegisterUser commands
  def execute(%User{uuid: nil}, _), do: {:error, :user_doesnt_exist}

  # DeleteUser
  # def execute(%User{deleted?: true}, %DeleteUser{}), do: nil

  # def execute(%User{product_count: count}, %DeleteUser{}) when count > 0,
  #   do: {:error, :user_has_linked_products}

  # def execute(%User{}, %DeleteUser{} = cmd), do: UserDeleted.new(cmd)

  # if User deleted we should return error for all but DeleteUser commands
  def execute(%User{deleted?: true}, _), do: {:error, :user_has_been_deleted}

  # RenameUser
  # def execute(%User{name: name}, %RenameUser{name: name}), do: nil

  # def execute(%User{uuid: uuid}, %RenameUser{user_uuid: uuid} = cmd), do: UserRenamed.new(cmd)

  # state mutators

  def apply(%User{} = user, %UserRegistered{} = event) do
    %User{
      user
      | uuid: event.user_uuid,
        email: event.email,
        name: event.name,
        identities: [event.identity]
    }
  end

  # def apply(
  #       %User{} = user,
  #       %UserDeleted{}
  #     ) do
  #   %User{
  #     user
  #     | deleted?: true
  #   }
  # end
end
