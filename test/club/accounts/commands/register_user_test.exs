defmodule Club.Accounts.Commands.RegisterUserTest do
  use Club.CommandCase,
    command: Club.Accounts.Commands.RegisterUser,
    factory: :new_user

  alias Club.Accounts.Commands.RegisterUser

  required_fields([
    :user_uuid,
    :email,
    :name,
    :identity
  ])

  fields(
    :string,
    [
      :name
    ]
  )

  fields(
    Ecto.UUID,
    [
      :user_uuid
    ]
  )

  basic_command_tests()

  describe "RegisterUser" do
    @describetag :unit

    test "incorrect user email - invalid command" do
      ~w(
        no_at_email.com
        just_a_string
      )
      |> Enum.each(fn email ->
        user = build(:new_user, %{email: email})

        %{errors: errors} = cmd = RegisterUser.new(user)
        refute cmd.valid?
        assert Enum.any?(errors, fn {field, {_, [validation: :format]}} -> field == :email end)
      end)
    end

    test "incorrect identity map (should have :prov and :uid keys) - invalid command" do
      [
        %{prov: "no uid field"},
        %{uid: "no prov field"},
        %{neither: "fields exist"},
        %{prov: "prov", uid: "1234", other_key: "irrelevant key"},
        %{}
      ]
      |> Enum.each(fn identity ->
        user = build(:new_user, %{identity: identity})

        %{errors: errors} = cmd = RegisterUser.new(user)
        refute cmd.valid?

        assert Enum.any?(errors, fn {field, {_, [validation: :identity, keys: _]}} ->
                 field == :identity
               end)
      end)
    end
  end
end
