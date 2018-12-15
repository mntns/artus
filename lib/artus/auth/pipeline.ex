defmodule Artus.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :artus,
    error_handler: Artus.Auth.ErrorHandler,
    module: Artus.Auth.Guardian

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
