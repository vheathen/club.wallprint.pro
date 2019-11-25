defmodule Club.Commanded do
  use Commanded.Application, otp_app: :club
  use Commanded.CommandDispatchValidation

  router(Club.Accounts.Router)
  router(Club.Brands.Router)
  router(Club.Devices.Router)
  router(Club.SurfaceTypes.Router)
  router(Club.Colors.Router)
end
