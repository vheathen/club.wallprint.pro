defmodule Club.Support.Config do
  @moduledoc false

  @app_name :club

  @defaults %{
              # all defaults are in config
            }

  @spec get(atom) :: term
  def get(key) when is_atom(key) do
    get(@app_name, key)
  end

  @doc """
  Fetches a value from the config, or from the environment if {:system, "VAR"}
  is provided.
  An optional default value can be provided if desired.
  ## Example
      iex> {test_var, expected_value} = System.get_env |> Enum.take(1) |> List.first
      ...> Application.put_env(:myapp, :test_var, {:system, test_var})
      ...> ^expected_value = #{__MODULE__}.get(:myapp, :test_var)
      ...> :ok
      :ok
      iex> Application.put_env(:myapp, :test_var2, 1)
      ...> 1 = #{__MODULE__}.get(:myapp, :test_var2)
      1
      iex> :default = #{__MODULE__}.get(:myapp, :missing_var, :default)
      :default
  """
  @spec get(atom, atom, term | nil) :: term
  def get(app, key, default \\ nil) when is_atom(app) and is_atom(key),
    do: get_cases(Application.get_env(app, key), key, default)

  defp get_cases({:system, env_var}, _, default) do
    case System.get_env(env_var) do
      nil -> default
      val -> val
    end
  end

  defp get_cases({:system, env_var, preconfigured_default}, _, _) do
    case System.get_env(env_var) do
      nil -> preconfigured_default
      val -> val
    end
  end

  defp get_cases(nil, key, default), do: Map.get(@defaults, key, default)
  defp get_cases(val, _key, _default), do: val

  @doc """
  Same as get/3, but returns the result as an integer.
  If the value cannot be converted to an integer, the
  default is returned instead.
  """
  @spec get_int(atom, atom, integer | nil) :: integer | nil
  def get_int(app, key, default \\ nil) do
    case get(app, key, nil) do
      nil ->
        default

      n when is_integer(n) ->
        n

      n ->
        case Integer.parse(n) do
          {i, _} -> i
          _ -> default
        end
    end
  end

  @spec get_int(atom) :: integer | nil
  def get_int(key) do
    get_int(@app_name, key)
  end

  def get_sub(key, subkey) do
    case get(@app_name, key) do
      nil -> nil
      opts -> Keyword.get(opts, subkey)
    end
  end

  @spec get_sub_int(atom, atom, integer | nil) :: integer | nil
  def get_sub_int(key, subkey, default \\ nil) do
    case get_sub(key, subkey) do
      nil ->
        default

      n when is_integer(n) ->
        n

      n ->
        case Integer.parse(n) do
          {i, _} -> i
          _ -> default
        end
    end
  end
end
