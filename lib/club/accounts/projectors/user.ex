defmodule Club.Accounts.Projectors.User do
  use Commanded.Projections.Ecto,
    application: Club.Commanded,
    repo: Club.ReadRepo,
    name: "accounts_user",
    consistency: Application.get_env(:my_app, :consistency, :eventual)

  alias Club.Accounts.Projections.User

  alias Club.Accounts.Events.{
    UserRegistered
  }

  @topic "domain:accounts"

  project(%UserRegistered{} = user_registered, _meta, fn multi ->
    Ecto.Multi.insert(
      multi,
      :user,
      %User{
        user_uuid: user_registered.user_uuid,
        name: user_registered.name,
        email: user_registered.email,
        email_confirmed?: false,
        state: "unverified",
        identities: [
          %User.Identity{
            prov: user_registered.identity.prov,
            uid: user_registered.identity.uid
          }
        ]
      }
    )
  end)

  def after_update(%UserRegistered{user_uuid: user_uuid}, _metadata, _changes) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      @topic,
      {:user_registered, %{user_uuid: user_uuid}}
    )

    :ok
  end
end
