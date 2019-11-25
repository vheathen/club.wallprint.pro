defmodule Club.ReadRepo.Migrations.CreateAccountsUsers do
  use Ecto.Migration

  def up do
    create table(:accounts_users, primary_key: false) do
      add :user_uuid, :binary_id, primary_key: true
      add :name, :string
      add :email, :string
      add :email_confirmed?, :boolean
      add :state, :string
      add :identities, :map, null: false, default: "[]"

      timestamps()
    end

    create index(:accounts_users, ["lower(name)"], name: :user_lower_name_idx)
    create index(:accounts_users, ["lower(email)"], name: :user_lower_email_idx)

    execute "CREATE INDEX user_identities_gin_idx ON accounts_users USING GIN (identities);"
  end

  def down do
    execute "DROP INDEX user_identities_gin_idx;"

    drop_if_exists(:user_lower_email_idx)
    drop_if_exists(:user_lower_name_idx)

    drop(:accounts_users)
  end
end
