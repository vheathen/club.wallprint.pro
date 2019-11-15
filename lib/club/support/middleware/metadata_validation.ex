defmodule Club.Support.Middleware.MetadataValidation do
  @behaviour Commanded.Middleware

  alias Commanded.Middleware.Pipeline

  import Pipeline

  def before_dispatch(%Pipeline{metadata: metadata} = pipeline) do
    case validate_metadata(metadata) do
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

  defp validate_metadata(metadata) do
    [
      validate_name(metadata),
      validate_uuid(metadata)
    ]
    |> Enum.reduce([], fn
      [], acc -> acc
      errors, acc -> acc ++ errors
    end)
    |> case do
      [] -> :ok
      errors -> {:error, errors}
    end
  end

  defp validate_name(%{user_name: user_name})
       when is_binary(user_name) and byte_size(user_name) > 0,
       do: []

  defp validate_name(%{user_name: ""}), do: [{:user_name, "can't be blank"}]
  defp validate_name(%{user_name: _}), do: [{:user_name, "not a string"}]
  defp validate_name(_), do: [{:user_name, "must be provided"}]

  defp validate_uuid(%{user_uuid: user_uuid}) do
    case UUID.info(user_uuid) do
      {:ok, _} -> []
      {:error, _} -> [{:user_uuid, "not a valid UUID"}]
    end
  end

  defp validate_uuid(_), do: [{:user_uuid, "must be provided"}]
end
