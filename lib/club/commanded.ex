defmodule Club.Commanded do
  use Commanded.Application, otp_app: :club
  use Commanded.CommandDispatchValidation

end
