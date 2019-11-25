defmodule Club.Accounts.Projections.User do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:user_uuid, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  schema "accounts_users" do
    field :name, :string
    field :email, :string
    field :email_confirmed?, :boolean
    field :state, :string

    embeds_many :identities, Identity do
      field :prov, :string
      field :uid, :string
    end

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :email_confirmed?, :state])
    |> cast_embed(:identities, with: &identities_changeset/2)
  end

  defp identities_changeset(schema, params) do
    schema
    |> cast(params, [:prov, :uid])
  end
end
