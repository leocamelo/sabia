defmodule Sabia.Repo do
  use Ecto.Repo,
    otp_app: :sabia,
    adapter: Ecto.Adapters.Postgres
end
