defmodule Club.Storage do
  @doc """
  Clear the event store and read store databases
  """
  def reset! do
    reset_readstore()
    reset_commanded_audit_store()
    # reset_commanded_scheduler_store()
    # reset_eventstore()

    {:ok, _} = Application.ensure_all_started(:club)
  end

  defp stop_all_apps do
    _ = Application.stop(:club)
    # _ = Application.stop(:commanded_scheduler)
    _ = Application.stop(:commanded_audit_middleware)
    _ = Application.stop(:commanded)
    # _ = Application.stop(:eventstore)
  end

  # defp reset_eventstore do
  #   stop_all_apps()
  #   _ = Application.stop(:commanded)

  #   config = EventStore.Config.parsed() |> EventStore.Config.default_postgrex_opts()

  #   {:ok, conn} = Postgrex.start_link(config)

  #   EventStore.Storage.Initializer.reset!(conn)
  # end

  defp reset_readstore do
    stop_all_apps()
    config = Application.get_env(:club, Club.ReadRepo)

    {:ok, conn} = Postgrex.start_link(config)

    Postgrex.query!(conn, truncate_readstore_tables(), [])
  end

  defp truncate_readstore_tables do
    """
    TRUNCATE TABLE
      brands_brands,
      projection_versions
    RESTART IDENTITY;
    """
  end

  defp reset_commanded_audit_store do
    stop_all_apps()

    config = Application.get_env(:commanded_audit_middleware, Commanded.Middleware.Auditing.Repo)

    {:ok, conn} = Postgrex.start_link(config)

    Postgrex.query!(conn, truncate_audit_tables(), [])
  end

  defp truncate_audit_tables do
    """
    TRUNCATE TABLE
      command_audit
    RESTART IDENTITY;
    """
  end

  # defp reset_commanded_scheduler_store do
  #   stop_all_apps()

  #   config = Application.get_env(:commanded_scheduler, Commanded.Scheduler.Repo)

  #   {:ok, conn} = Postgrex.start_link(config)

  #   Postgrex.query!(conn, truncate_scheduler_tables(), [])
  # end

  # defp truncate_scheduler_tables do
  #   """
  #   TRUNCATE TABLE
  #     schedules,
  #     projection_versions
  #   RESTART IDENTITY;
  #   """
  # end
end
