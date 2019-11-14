defmodule Club.Support.Middleware.Uniqueness do
  @behaviour Commanded.Middleware

  defprotocol UniqueFields do
    @fallback_to_any true
    @doc "Returns unique fields for the command"
    def unique(command)
  end

  defimpl UniqueFields, for: Any do
    def unique(_command), do: []
  end

  alias Commanded.Middleware.Pipeline

  import Pipeline

  def before_dispatch(%Pipeline{command: command} = pipeline) do
    case ensure_uniqueness(command) do
      :ok ->
        pipeline

      {:error, errors} ->
        pipeline
        |> respond({:error, :validation_failure, errors})
        |> halt()
    end
  end

  def after_dispatch(pipeline), do: pipeline
  def after_failure(pipeline), do: pipeline

  defp ensure_uniqueness(command) do
    ensure_uniqueness(command, get_adapter())
  end

  defp ensure_uniqueness(_command, nil) do
    require Logger

    Logger.debug("No unique cache adapter defined in config! Assume the value is unique.",
      label: "#{__MODULE__}"
    )

    :ok
  end

  defp ensure_uniqueness(command, adapter) do
    command
    |> UniqueFields.unique()
    |> ensure_uniqueness(command, adapter, [], [])
  end

  defp ensure_uniqueness([record | rest], command, adapter, errors, to_release) do
    {_, error_message, _, _} = record = expand_record(record)
    label = get_label(record)

    case claim(record, command, adapter) do
      {id, value, owner} ->
        ensure_uniqueness(rest, command, adapter, errors, [{id, value, owner} | to_release])

      _ ->
        ensure_uniqueness(rest, command, adapter, [{label, error_message} | errors], to_release)
    end
  end

  defp ensure_uniqueness([], _command, _adapter, [], _to_release), do: :ok
  defp ensure_uniqueness([], _command, _adapter, errors, []), do: {:error, errors}

  defp ensure_uniqueness([], command, adapter, errors, to_release) do
    Enum.each(to_release, &release(&1, adapter))

    ensure_uniqueness([], command, adapter, errors, [])
  end

  defp claim({fields, _, owner, opts}, command, adapter)
       when is_list(fields) do
    value =
      fields
      |> Enum.reduce([], fn field_name, acc ->
        ignore_case = Keyword.get(opts, :ignore_case)

        [get_field_value(command, field_name, ignore_case) | acc]
      end)

    key = Module.concat(fields)
    command = %{key => value}
    entity = {key, "", owner, opts}
    claim(entity, command, adapter)
  end

  defp claim({field_name, _, owner, opts}, command, adapter)
       when is_atom(field_name) do
    ignore_case? = Keyword.get(opts, :ignore_case)
    value = get_field_value(command, field_name, ignore_case?)

    case adapter.claim(field_name, value, owner) do
      :ok -> {field_name, value, owner}
      error -> error
    end
  end

  defp release({id, value, owner}, adapter), do: adapter.release(id, value, owner)

  defp expand_record({one, two, three}), do: {one, two, three, []}
  defp expand_record(entity), do: entity

  defp get_field_value(command, field_name, ignore_case)

  defp get_field_value(command, field_name, ignore_case) when is_list(ignore_case),
    do: get_field_value(command, field_name, Enum.any?(ignore_case, &(&1 == field_name)))

  defp get_field_value(command, field_name, field_name),
    do: get_field_value(command, field_name, true)

  defp get_field_value(command, field_name, true),
    do: command |> get_field_value(field_name, false) |> downcase()

  defp get_field_value(command, field_name, _), do: Map.get(command, field_name)

  defp downcase(value) when is_binary(value), do: String.downcase(value)
  defp downcase(value), do: value

  defp get_label({entity, _, _, opts}), do: Keyword.get(opts, :label, entity)

  defp get_adapter, do: Club.Support.Config.get_sub(Club.Support.Unique, :adapter)
end
