defmodule Club.CommandCase do
  @moduledoc """
  This module defines the setup for a domain commands test.
  """

  use ExUnit.CaseTemplate

  import Club.Factory

  @field_types [
    :string,
    :integer,
    # :float,
    Ecto.UUID
    # :url
  ]

  using(opts) do
    command =
      Keyword.get(opts, :command) ||
        raise "use CommandCase, command: CommandModule, factory: :factory_name"

    factory =
      Keyword.get(opts, :factory) ||
        raise "use CommandCase, command: CommandModule, factory: :factory_name"

    fields_acc = for type <- @field_types, into: %{}, do: {type, []}

    quote do
      import Club.Factory
      import Club.CommandCase

      @command unquote(command)
      @factory unquote(factory)
      @test_retries 10

      @fields unquote(Macro.escape(fields_acc))

      @required_fields []
      @optional_fields []
      @all_fields []
    end
  end

  setup do
    {:ok, _} = Application.ensure_all_started(:club)

    default_settings = Application.get_all_env(:club)

    on_exit(fn ->
      Application.put_all_env([{:club, default_settings}])
    end)

    :ok
  end

  @doc """
  Macro for running basic tests:
    - checks for all fields (required + optional)
    - checks that correct attributes, provided by a factory, allow to create a valid command
    - checks that without any of the required fields a new command becomes invalid
    - checks that without any optional fields a new command still valid
    - checks for cast error, mostly to be sure types are set correctly
  """
  defmacro basic_command_tests do
    quote do
      describe "#{@command}" do
        @describetag :unit

        test_command_has_all_fields()

        test_command_is_valid_with_valid_attributes()

        test_command_is_invalid_without_required_fields()

        test_command_is_valid_without_optional_fields()

        test_command_field_types()
      end
    end
  end

  defmacro required_fields(fields) when is_list(fields) do
    quote do
      @required_fields (unquote(fields) ++ @required_fields) |> Enum.sort()
      @all_fields (unquote(fields) ++ @all_fields) |> Enum.sort()
    end
  end

  defmacro optional_fields(fields) when is_list(fields) do
    quote do
      @optional_fields (unquote(fields) ++ @optional_fields) |> Enum.sort()
      @all_fields (unquote(fields) ++ @all_fields) |> Enum.sort()
    end
  end

  defmacro get_required_fields, do: quote(do: @required_fields)
  defmacro get_optional_fields, do: quote(do: @optional_fields)
  defmacro get_all_fields, do: quote(do: @all_fields)

  defmacro fields(type, fields) do
    quote do
      @fields Map.put(@fields, unquote(type), unquote(fields))
    end
  end

  #####
  defmacro test_command_has_all_fields do
    quote do
      test "should contain all necessary fields" do
        check_command_has_all_fields(@command, @all_fields)
      end
    end
  end

  @spec check_command_has_all_fields(atom(), list()) :: true | false
  def check_command_has_all_fields(command, fields_list) when is_list(fields_list) do
    assert fields_list == command |> struct() |> Map.from_struct() |> Map.keys() |> Enum.sort()
  end

  ###
  defmacro test_command_is_valid_with_valid_attributes do
    quote do
      test "with correct attributes should allow to create a valid command" do
        check_command_is_valid_with_valid_attributes(@command, @factory, retries: @test_retries)
      end
    end
  end

  @spec check_command_is_valid_with_valid_attributes(atom(), atom(), keyword) :: [any]
  def check_command_is_valid_with_valid_attributes(command, factory, opts \\ []) do
    for _ <- 1..Keyword.get(opts, :retries, 1),
        do: assert(command.new(build(factory)).valid?)
  end

  ###
  defmacro test_command_is_invalid_without_required_fields do
    quote do
      test "without one of the required fields - invalid command" do
        check_command_is_invalid_without_required_field(@command, @factory, @required_fields,
          retries: @test_retries
        )
      end
    end
  end

  @spec check_command_is_invalid_without_required_field(atom(), atom(), list(), keyword()) :: [
          any
        ]
  def check_command_is_invalid_without_required_field(
        command,
        factory,
        required_fields,
        opts \\ []
      ) do
    for _ <- 1..Keyword.get(opts, :retries, 1) do
      for req_field <- required_fields do
        data = factory |> build() |> Map.delete(req_field)

        %{errors: errors} = cmd = command.new(data)
        refute cmd.valid?

        assert Enum.any?(
                 errors,
                 fn
                   {^req_field, {_, [validation: :required]}} ->
                     true

                   _ ->
                     false
                 end
               )
      end
    end
  end

  ###
  defmacro test_command_is_valid_without_optional_fields() do
    quote do
      test "without any of the optional fields - valid command" do
        check_command_is_valid_without_optional_fields(@command, @factory, @optional_fields,
          retries: @test_retries
        )
      end
    end
  end

  @spec check_command_is_valid_without_optional_fields(atom(), atom(), list(), keyword()) :: [
          any
        ]
  def check_command_is_valid_without_optional_fields(
        command,
        factory,
        optional_fields,
        opts \\ []
      ) do
    for _ <- 1..Keyword.get(opts, :retries, 1) do
      for opt_field <- optional_fields do
        data = factory |> build() |> Map.delete(opt_field)
        assert command.new(data).valid?
      end
    end
  end

  ###
  defmacro test_command_field_types do
    for type <- @field_types do
      quote do
        test "with non-#{unquote(type)} data for #{unquote(type)} fields - invalid command" do
          check_command_fields_type(
            @command,
            @factory,
            unquote(type),
            @fields[unquote(type)],
            retries: @test_retries
          )
        end
      end
    end
  end

  def check_command_fields_type(command, factory, type, field_names, opts \\ []) do
    for field_name <- field_names do
      for _ <- 1..Keyword.get(opts, :retries, 1) do
        type
        |> get_incorrect_data()
        |> Enum.each(fn incorrect_data_piece ->
          data = build(factory, %{field_name => incorrect_data_piece})

          %{errors: errors} = cmd = command.new(data)
          refute cmd.valid?

          assert Enum.any?(
                   errors,
                   fn
                     {^field_name, {_, [type: ^type, validation: :cast]}} ->
                       true

                     _ ->
                       false
                   end
                 )
        end)
      end
    end
  end

  @spec get_incorrect_data(atom()) :: [...]
  def get_incorrect_data(:string) do
    [
      Faker.Random.Elixir.random_between(-2_000_000_000, 2_000_000_000),
      Faker.Random.Elixir.random_uniform(),
      :simple_atom,
      :"less simple atom",
      'charlist'
    ]
  end

  def get_incorrect_data(Ecto.UUID) do
    [
      Faker.Random.Elixir.random_between(-2_000_000_000, 2_000_000_000),
      Faker.String.base64(32),
      Faker.String.base64(64),
      Faker.Random.Elixir.random_uniform(),
      :simple_atom,
      :"less simple atom",
      'charlist'
    ]
  end

  def get_incorrect_data(:integer) do
    [
      Faker.Random.Elixir.random_between(-2_000_000_000, 2_000_000_000),
      Faker.String.base64(32),
      Faker.String.base64(64),
      Faker.Random.Elixir.random_uniform(),
      :simple_atom,
      :"less simple atom",
      'charlist'
    ]
  end
end
