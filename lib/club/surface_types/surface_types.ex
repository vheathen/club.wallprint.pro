defmodule Club.SurfaceTypes do
  @moduledoc """
  SurfaceTypes domain public API
  """

  alias Club.ReadRepo, as: Repo

  alias Club.Commanded

  alias Club.SurfaceTypes.Commands.{
    AddSurfaceType,
    RenameSurfaceType,
    DeleteSurfaceType
  }

  alias Club.SurfaceTypes.Queries.NameExists

  @spec add_surface_type(surface_type :: map(), metadata :: maybe_improper_list | map) ::
          {:ok, Ecto.UUID.t()} | {:error, any}
  def add_surface_type(surface_type, metadata)
      when (is_map(surface_type) or is_list(surface_type)) and
             (is_map(metadata) or is_list(metadata)) do
    surface_type_uuid =
      surface_type |> Enum.into(%{}) |> Map.get(:surface_type_uuid, UUID.uuid4())

    cmd =
      surface_type
      |> Map.put(:surface_type_uuid, surface_type_uuid)
      |> AddSurfaceType.new()

    case Commanded.validate_and_dispatch(cmd, metadata: metadata) do
      :ok ->
        {:ok, surface_type_uuid}

      reply ->
        reply
    end
  end

  @spec rename_surface_type(rename_surface_type :: map(), metadata :: maybe_improper_list | map) ::
          :ok | {:error, any}
  def rename_surface_type(rename_surface_type, metadata)
      when (is_map(rename_surface_type) or is_list(rename_surface_type)) and
             (is_map(metadata) or is_list(metadata)) do
    cmd = RenameSurfaceType.new(rename_surface_type)

    Commanded.validate_and_dispatch(cmd, metadata: metadata)
  end

  @spec delete_surface_type(delete_surface_type :: map(), metadata :: maybe_improper_list | map) ::
          :ok | {:error, any}
  def delete_surface_type(delete_surface_type, metadata)
      when (is_map(delete_surface_type) or is_list(delete_surface_type)) and
             (is_map(metadata) or is_list(metadata)) do
    cmd = DeleteSurfaceType.new(delete_surface_type)

    Commanded.validate_and_dispatch(cmd, metadata: metadata)
  end

  @spec surface_type_unique?(surface_type :: map()) :: boolean()
  def surface_type_unique?(%{name: name}) do
    case Repo.one(NameExists.new(name)) do
      true -> false
      nil -> true
    end
  end

  def surface_type_unique?(%Ecto.Changeset{} = cmd) do
    cmd
    |> Ecto.Changeset.apply_changes()
    |> surface_type_unique?()
  end
end
