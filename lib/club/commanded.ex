defmodule Club.Commanded do
  use Commanded.Application, otp_app: :club
  use Commanded.CommandDispatchValidation

  router(Club.Brands.Router)
  router(Club.Devices.Router)
end
