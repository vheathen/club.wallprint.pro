defmodule ScribitWeb.ViewHelpers do
  @moduledoc false

  alias PowAssent.Plug
  alias PowAssent.Phoenix.AuthorizationController

  @doc """
  Generates list of authorization paths for all configured providers.

  The list of providers will be fetched from the configuration, and
  `authorization_link/2` will be called on each.
  """
  @spec provider_paths(Conn.t()) :: [{String.t(), HTML.safe()}]
  def provider_paths(conn) do
    available_providers = Plug.available_providers(conn)
    providers_for_user = Plug.providers_for_current_user(conn)

    available_providers
    |> Enum.map(&{&1, &1 in providers_for_user})
    |> Enum.map(fn
      # {provider, true} -> deauthorization_link(conn, provider)
      {provider, false} -> {provider, authorization_path(conn, provider)}
    end)
  end

  @doc """
  Generates a path for an authorization link for a provider.

  The path is used to make a link to sign up or register a user using a provider. If
  `:invited_user` is assigned to the conn, the invitation token will be passed
  on through the URL query params.
  """
  @spec authorization_path(Conn.t(), atom()) :: HTML.safe()
  def authorization_path(conn, provider) do
    query_params = authorization_link_query_params(conn)

    AuthorizationController.routes(conn).path_for(
      conn,
      AuthorizationController,
      :new,
      [provider],
      query_params
    )
  end

  defp authorization_link_query_params(%{assigns: %{invited_user: %{invitation_token: token}}}),
    do: [invitation_token: token]

  defp authorization_link_query_params(_conn), do: []
end
