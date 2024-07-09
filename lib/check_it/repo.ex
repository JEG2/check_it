defmodule CheckIt.Repo do
  use Ecto.Repo,
    otp_app: :check_it,
    adapter: Ecto.Adapters.Postgres
end
