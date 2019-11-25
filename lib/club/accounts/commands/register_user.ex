defmodule Club.Accounts.Commands.RegisterUser do
  use Commanded.Command,
    user_uuid: Ecto.UUID,
    email: :string,
    name: :string,
    identity: :map

  @required_fields [
    :user_uuid,
    :email,
    :name,
    :identity
  ]

  import Club.Accounts.Validators.Identity

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/.+@.+\..+/)
    |> validate_identity_format(:identity)
  end
end

defimpl Club.Support.Middleware.Uniqueness.UniqueFields, for: Club.Accounts.Commands.RegisterUser do
  alias Club.Accounts.Commands.RegisterUser
  alias Club.Accounts

  def unique(%RegisterUser{user_uuid: user_uuid}),
    do: [
      {:name, "has already taken", user_uuid,
       ignore_case: true, label: :name, is_unique: &is_unique/4},
      {:email, "has already taken", user_uuid,
       ignore_case: true, label: :email, is_unique: &is_unique/4}
    ]

  def is_unique(:name, value, _owner, _opts), do: Accounts.user_name_unique?(value)
  def is_unique(:email, value, _owner, _opts), do: Accounts.user_email_unique?(value)
end
