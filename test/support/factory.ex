defmodule Club.Factory do
  use ExMachina.Ecto, repo: Club.ReadRepo

  # Brands domain
  use Club.Factories.Brands
  use Club.Factories.Devices
  use Club.Factories.SurfaceTypes
  use Club.Factories.Colors
  use Club.Factories.Accounts

  def metadata_factory do
    %{
      user_uuid: UUID.uuid4(),
      user_name: Faker.Name.En.name()
    }
  end
end
