defmodule Club.Colors do
  @moduledoc """
  Colors domain public API
  """

  alias Club.Commanded

  alias Club.ReadRepo, as: Repo

  alias Club.Colors.Commands.{
    AddColor,
    RenameColor,
    UpdateColorHex,
    DeleteColor
  }

  alias Club.Colors.Queries.NameExists

  @spec add_color(color :: map(), metadata :: maybe_improper_list | map) ::
          {:ok, Ecto.UUID.t()} | {:error, any}
  def add_color(color, metadata)
      when (is_map(color) or is_list(color)) and
             (is_map(metadata) or is_list(metadata)) do
    color_uuid = color |> Enum.into(%{}) |> Map.get(:color_uuid, UUID.uuid4())

    cmd =
      color
      |> Map.put(:color_uuid, color_uuid)
      |> AddColor.new()

    case Commanded.validate_and_dispatch(cmd, metadata: metadata) do
      :ok ->
        {:ok, color_uuid}

      reply ->
        reply
    end
  end

  @spec rename_color(rename_color :: map(), metadata :: maybe_improper_list | map) ::
          :ok | {:error, any}
  def rename_color(rename_color, metadata)
      when (is_map(rename_color) or is_list(rename_color)) and
             (is_map(metadata) or is_list(metadata)) do
    cmd = RenameColor.new(rename_color)

    Commanded.validate_and_dispatch(cmd, metadata: metadata)
  end

  @spec update_color_hex(update_hex :: map(), metadata :: maybe_improper_list | map) ::
          :ok | {:error, any}
  def update_color_hex(update_hex, metadata)
      when (is_map(update_hex) or is_list(update_hex)) and
             (is_map(metadata) or is_list(metadata)) do
    cmd = UpdateColorHex.new(update_hex)

    Commanded.validate_and_dispatch(cmd, metadata: metadata)
  end

  @spec delete_color(delete_color :: map(), metadata :: maybe_improper_list | map) ::
          :ok | {:error, any}
  def delete_color(delete_color, metadata)
      when (is_map(delete_color) or is_list(delete_color)) and
             (is_map(metadata) or is_list(metadata)) do
    cmd = DeleteColor.new(delete_color)

    Commanded.validate_and_dispatch(cmd, metadata: metadata)
  end
end
