defmodule Club.Support.Middleware.MetadataValidationTest do
  use ExUnit.Case

  alias Commanded.Middleware.Pipeline

  alias Club.Support.Middleware.MetadataValidation

  describe "MetadataValidation middleware should" do
    @describetag :unit

    test "halt with error if metadata doesn't contain user_name and user_uuid" do
      meta = %{}
      p = MetadataValidation.before_dispatch(%Pipeline{metadata: meta})
      assert p.halted

      assert p.response ==
               {:error, :validation_failure,
                [{:user_name, "must be provided"}, {:user_uuid, "must be provided"}]}
    end

    test "halt with error if metadata doesn't contain user_name" do
      meta = %{user_uuid: UUID.uuid4()}
      p = MetadataValidation.before_dispatch(%Pipeline{metadata: meta})
      assert p.halted
      assert p.response == {:error, :validation_failure, [{:user_name, "must be provided"}]}
    end

    test "halt with error if metadata contains user_name which is not a string" do
      meta = %{user_name: 222_222, user_uuid: UUID.uuid4()}
      p = MetadataValidation.before_dispatch(%Pipeline{metadata: meta})
      assert p.halted
      assert p.response == {:error, :validation_failure, [{:user_name, "not a string"}]}
    end

    test "halt with error if metadata doesn't contain user_uuid" do
      meta = %{user_name: "some name"}
      p = MetadataValidation.before_dispatch(%Pipeline{metadata: meta})
      assert p.halted
      assert p.response == {:error, :validation_failure, [{:user_uuid, "must be provided"}]}
    end

    test "halt with error if metadata contains user_uuid which is not a UUID" do
      meta = %{user_name: 222_222, user_uuid: "non-uuid string"}
      p = MetadataValidation.before_dispatch(%Pipeline{metadata: meta})
      assert p.halted

      assert p.response ==
               {:error, :validation_failure,
                [{:user_name, "not a string"}, {:user_uuid, "not a valid UUID"}]}
    end

    test "continue if metadata contains correct necessary data" do
      meta = %{user_name: "some name", user_uuid: UUID.uuid4()}
      p = MetadataValidation.before_dispatch(%Pipeline{metadata: meta})
      refute p.halted
    end
  end
end
