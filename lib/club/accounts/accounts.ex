defmodule Club.Accounts do
  @moduledoc """
  Accounts boundary
  """

  alias Club.Commanded

  alias Club.ReadRepo, as: Repo

  alias Club.Accounts.Commands.{
    RegisterUser
  }

  alias Club.Accounts.Queries.{
    UserNameExists,
    UserEmailExists
  }

  @spec register_user(user :: map(), metadata :: maybe_improper_list | map) ::
          {:ok, Ecto.UUID.t()} | {:error, any}
  def register_user(user, metadata)
      when (is_map(user) or is_list(user)) and
             (is_map(metadata) or is_list(metadata)) do
    user_uuid = user |> Enum.into(%{}) |> Map.get(:user_uuid, UUID.uuid4())

    cmd =
      user
      |> Map.put(:user_uuid, user_uuid)
      |> RegisterUser.new()

    case Commanded.validate_and_dispatch(cmd, metadata: metadata) do
      :ok ->
        {:ok, user_uuid}

      reply ->
        reply
    end
  end

  @spec user_name_unique?(name :: String.t()) :: boolean()
  def user_name_unique?(name) do
    case Repo.one(UserNameExists.new(name)) do
      true -> false
      nil -> true
    end
  end

  @spec user_email_unique?(email :: String.t()) :: boolean()
  def user_email_unique?(email) do
    case Repo.one(UserEmailExists.new(email)) do
      true -> false
      nil -> true
    end
  end
end
