defmodule ScribitWeb.AuthHelper do
  @moduledoc """
  Handle pow user in LiveView.

  Will assign the current user and periodically check that the session is still
  active. `session_expired/1` will be called when session expires.

  Configuration options:

  * `:otp_app` - the app name
  * `:interval` - how often the session has to be checked, defaults 60s

      defmodule ScribitWeb.SomeViewLive do
        use PhoenixLiveView
        use ScribitWeb.AuthHelper, otp_app: :scribit

        def mount(session, socket) do
          socket = mount_user(socket, session)

          # ...
        end

        def session_expired(socket) do
          # handle session expiration

          {:noreply, socket}
        end
      end
  """
  require Logger

  import Phoenix.LiveView, only: [assign: 3]

  defmacro __using__(opts) do
    config = [otp_app: opts[:otp_app]]
    session_key = Pow.Plug.prepend_with_namespace(config, "auth")
    interval = Keyword.get(opts, :interval, :timer.seconds(60))

    config = [
      session_key: session_key,
      interval: interval,
      module: __CALLER__.module
    ]

    quote do
      # ++ [module: __MODULE__]
      @config unquote(Macro.escape(config))

      def mount_user(socket, session),
        do: unquote(__MODULE__).mount_user(socket, self(), session, config())

      def handle_info(:pow_auth_ttl, socket) do
        {
          :noreply,
          unquote(__MODULE__).handle_auth_ttl(socket, self(), config())
        }
      end

      def config do
        unquote(Macro.escape(opts[:otp_app]))
        |> Application.get_env(:pow, [])
        |> Keyword.merge(@config)
      end
    end
  end

  @spec mount_user(Phoenix.LiveView.Socket.t(), pid(), map(), keyword()) ::
          Phoenix.LiveView.Socket.t()
  def mount_user(socket, pid, session, config) do
    session = Map.fetch!(session, config[:session_key] |> String.to_existing_atom())

    socket
    |> assign_current_session(session, config)
    |> assign_current_user(config)
    |> init_auth_check(pid, config)
  end

  defp init_auth_check(socket, pid, config) do
    case Phoenix.LiveView.connected?(socket) do
      true ->
        handle_auth_ttl(socket, pid, config)

      false ->
        socket
    end
  end

  @spec handle_auth_ttl(Phoenix.LiveView.Socket.t(), pid(), keyword()) ::
          Phoenix.LiveView.Socket.t()
  def handle_auth_ttl(socket, pid, config) do
    interval = Pow.Config.get(config, :interval)
    module = Pow.Config.get(config, :module)

    case pow_session_active?(socket, config) do
      true ->
        Logger.info("[#{__MODULE__}] User session still active")

        Process.send_after(pid, :pow_auth_ttl, interval)

        socket

      false ->
        Logger.info("[#{__MODULE__}] User session no longer active")

        socket
        |> assign_current_session(nil, config)
        |> assign_current_user(config)
        |> module.session_expired()
    end
  end

  defp assign_current_session(socket, user, config) do
    assign_key = Pow.Config.get(config, :session_key)

    assign(socket, assign_key, user)
  end

  defp get_current_session(socket, config) do
    assign_key = Pow.Config.get(config, :session_key)

    socket.assigns |> Map.get(assign_key)
  end

  defp assign_current_user(socket, config) do
    assign_key = Pow.Config.get(config, :current_user_assigns_key, :current_user)

    case pow_session_active?(socket, config) do
      true ->
        assign(socket, assign_key, get_current_user(socket, config))

      false ->
        assign(socket, assign_key, nil)
    end
  end

  defp get_current_user(socket, config) do
    {store, store_config} = store(config)

    store_config
    |> store.get(get_current_session(socket, config))
    |> case do
      :not_found -> :not_found
      {user, _inserted_at} -> user
    end
  end

  defp pow_session_active?(socket, config) do
    socket
    |> get_current_user(config)
    |> case do
      :not_found -> false
      _ -> true
    end
  end

  defp store(config) do
    case Pow.Config.get(config, :session_store, default_store(config)) do
      {store, store_config} -> {store, store_config}
      store -> {store, []}
    end
  end

  defp default_store(config) do
    backend = Pow.Config.get(config, :cache_store_backend, Pow.Store.Backend.EtsCache)

    {Pow.Store.CredentialsCache, [backend: backend]}
  end
end
