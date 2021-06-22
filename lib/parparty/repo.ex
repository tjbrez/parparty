defmodule Parparty.Repo do
  use Ecto.Repo,
    otp_app: :parparty,
    adapter: Ecto.Adapters.Postgres
end
