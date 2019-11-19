defmodule Club.Colors.Aggregates.Color do
  @derive Jason.Encoder

  defstruct uuid: nil,
            name: nil,
            hex: "",
            thing_count: 0,
            things: [],
            deleted?: false

  alias Club.Colors.Aggregates.Color

  alias Club.Colors.Commands.{
    AddColor,
    RenameColor,
    UpdateColorHex,
    UseColor,
    StopUsingColor,
    DeleteColor
  }

  alias Club.Colors.Events.{
    ColorAdded,
    ColorRenamed,
    ColorHexUpdated,
    ColorUsed,
    ColorUsageStopped,
    ColorDeleted
  }

  # AddColor
  def execute(%Color{uuid: nil}, %AddColor{} = cmd), do: ColorAdded.new(cmd)

  def execute(%Color{}, %AddColor{}), do: {:error, :color_already_exists}

  # if Color doesn't exists we should return error for all but AddColor commands
  def execute(%Color{uuid: nil}, _), do: {:error, :color_doesnt_exist}

  # DeleteColor
  def execute(%Color{deleted?: true}, %DeleteColor{}), do: nil

  def execute(%Color{thing_count: count}, %DeleteColor{}) when count > 0,
    do: {:error, :color_used}

  def execute(%Color{}, %DeleteColor{} = cmd), do: ColorDeleted.new(cmd)

  # if Color deleted we should return error for all but DeleteColor commands
  def execute(%Color{deleted?: true}, _), do: {:error, :color_has_been_deleted}

  # RenameColor
  def execute(%Color{name: name}, %RenameColor{name: name}), do: nil

  def execute(%Color{uuid: uuid}, %RenameColor{color_uuid: uuid} = cmd), do: ColorRenamed.new(cmd)

  UpdateColorHex
  def execute(%Color{hex: hex}, %UpdateColorHex{hex: hex}), do: nil

  def execute(%Color{uuid: uuid}, %UpdateColorHex{color_uuid: uuid} = cmd),
    do: ColorHexUpdated.new(cmd)

  # UseColor
  def execute(
        %Color{things: things},
        %UseColor{thing_uuid: thing_uuid} = cmd
      ) do
    case Enum.any?(things, &(&1 == thing_uuid)) do
      true -> nil
      _ -> ColorUsed.new(cmd)
    end
  end

  # StopUsingColor
  def execute(
        %Color{things: things},
        %StopUsingColor{thing_uuid: thing_uuid} = cmd
      ) do
    case Enum.any?(things, &(&1 == thing_uuid)) do
      true -> ColorUsageStopped.new(cmd)
      _ -> nil
    end
  end

  # state mutators

  def apply(%Color{} = color, %ColorAdded{} = event) do
    %Color{
      color
      | uuid: event.color_uuid,
        name: event.name,
        hex: event.hex
    }
  end

  def apply(%Color{} = color, %ColorRenamed{name: name}) do
    %Color{
      color
      | name: name
    }
  end

  def apply(%Color{} = color, %ColorHexUpdated{hex: hex}) do
    %Color{
      color
      | hex: hex
    }
  end

  def apply(
        %Color{thing_count: thing_count, things: things} = color,
        %ColorUsed{
          thing_uuid: thing_uuid
        }
      ) do
    %Color{
      color
      | thing_count: thing_count + 1,
        things: [thing_uuid | things]
    }
  end

  def apply(
        %Color{thing_count: thing_count, things: things} = color,
        %ColorUsageStopped{
          thing_uuid: thing_uuid
        }
      ) do
    %Color{
      color
      | thing_count: thing_count - 1,
        things: things -- [thing_uuid]
    }
  end

  def apply(
        %Color{} = color,
        %ColorDeleted{}
      ) do
    %Color{
      color
      | deleted?: true
    }
  end
end
