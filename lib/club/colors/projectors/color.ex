defmodule Club.Colors.Projectors.Color do
  use Commanded.Projections.Ecto,
    application: Club.Commanded,
    repo: Club.ReadRepo,
    name: "colors_color",
    consistency: Application.get_env(:my_app, :consistency, :eventual)

  alias Club.Colors.Projections.Color

  alias Club.Colors.Events.{
    ColorAdded,
    ColorRenamed,
    ColorHexUpdated,
    ColorUsed,
    ColorUsageStopped,
    ColorDeleted
  }

  @topic "domain:colors"

  project(%ColorAdded{} = color_added, _meta, fn multi ->
    Ecto.Multi.insert(
      multi,
      :color,
      %Color{
        color_uuid: color_added.color_uuid,
        name: color_added.name,
        hex: color_added.hex,
        thing_count: 0
      }
    )
  end)

  def after_update(%ColorAdded{color_uuid: color_uuid}, _metadata, _changes) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      @topic,
      {:color_added, %{color_uuid: color_uuid}}
    )

    :ok
  end

  project(%ColorDeleted{color_uuid: color_uuid}, _meta, fn multi ->
    Ecto.Multi.delete_all(
      multi,
      :color,
      color_query(color_uuid)
    )
  end)

  def after_update(%ColorDeleted{color_uuid: color_uuid}, _metadata, _changes) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      @topic,
      {:color_deleted, %{color_uuid: color_uuid}}
    )

    :ok
  end

  project(
    %ColorRenamed{color_uuid: color_uuid, name: name},
    _meta,
    fn multi ->
      update_color(multi, color_uuid, set: [name: name])
    end
  )

  def after_update(
        %ColorRenamed{color_uuid: color_uuid, name: name},
        _metadata,
        _changes
      ) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      @topic,
      {:color_renamed, %{color_uuid: color_uuid, name: name}}
    )

    :ok
  end

  project(
    %ColorHexUpdated{color_uuid: color_uuid, hex: hex},
    _meta,
    fn multi ->
      update_color(multi, color_uuid, set: [hex: hex])
    end
  )

  def after_update(
        %ColorHexUpdated{color_uuid: color_uuid, hex: hex},
        _metadata,
        _changes
      ) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      @topic,
      {:hex_updated, %{color_uuid: color_uuid, hex: hex}}
    )

    :ok
  end

  project(
    %ColorUsed{color_uuid: color_uuid},
    _meta,
    fn multi ->
      update_color(multi, color_uuid, inc: [thing_count: 1])
    end
  )

  def after_update(
        %ColorUsed{color_uuid: color_uuid},
        _metadata,
        _changes
      ) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      @topic,
      {:color_used, %{color_uuid: color_uuid}}
    )

    :ok
  end

  project(
    %ColorUsageStopped{color_uuid: color_uuid},
    _meta,
    fn multi ->
      update_color(multi, color_uuid, inc: [thing_count: -1])
    end
  )

  def after_update(
        %ColorUsageStopped{color_uuid: color_uuid},
        _metadata,
        _changes
      ) do
    Phoenix.PubSub.broadcast(
      Club.EventBus,
      @topic,
      {:color_usage_stopped, %{color_uuid: color_uuid}}
    )

    :ok
  end

  defp update_color(multi, color_uuid, changes) do
    Ecto.Multi.update_all(multi, :color, color_query(color_uuid), changes)
  end

  defp color_query(color_uuid) do
    from b in Color, where: b.color_uuid == ^color_uuid
  end
end
