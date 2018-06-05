defmodule Artus.Repo do
  use Ecto.Repo, otp_app: :artus
  use Scrivener, page_size: 20
end
