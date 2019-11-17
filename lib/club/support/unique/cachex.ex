defmodule Club.Support.Unique.Cachex do
  @behaviour Club.Support.Unique

  require Cachex.Spec

  @by_value_key :bv
  @by_owner_key :bo

  @impl true
  def child_spec do
    %{
      id: __MODULE__,
      start: {Cachex, :start, [__MODULE__, [expiration: Cachex.Spec.expiration(default: ttl())]]}
    }
  end

  @impl true
  def claim(id, value, owner) do
    __MODULE__
    |> Cachex.get_and_update({@by_value_key, id, value}, fn
      nil ->
        :ok = release(id, owner)

        Cachex.put(__MODULE__, {@by_owner_key, id, owner}, value)
        {:commit, owner}

      ^owner ->
        {:ignore, :ok}

      {:error, error} ->
        {:ignore, {:error, error}}

      _ ->
        {:ignore, {:error, :already_exists}}
    end)
    |> case do
      {:commit, _} -> :ok
      {:ignore, result} -> result
    end
  end

  @impl true
  def release(id, value, owner) do
    case Cachex.get(__MODULE__, {@by_value_key, id, value}) do
      {:ok, nil} ->
        :ok

      {:ok, ^owner} ->
        Cachex.del(__MODULE__, {@by_value_key, id, value})
        Cachex.del(__MODULE__, {@by_owner_key, id, owner})
        :ok

      {:ok, _} ->
        {:error, :claimed_by_another_owner}

      _ ->
        {:error, :unknown_error}
    end
  end

  @impl true
  def release(id, owner) do
    case Cachex.get(__MODULE__, {@by_owner_key, id, owner}) do
      {:ok, nil} ->
        :ok

      {:ok, value} ->
        Cachex.del(__MODULE__, {@by_value_key, id, value})
        Cachex.del(__MODULE__, {@by_owner_key, id, owner})
        :ok

      _ ->
        {:error, :unknown_error}
    end
  end

  defp ttl do
    Club.Support.Config.get_sub(Club.Support.Unique, :ttl)
  end
end
