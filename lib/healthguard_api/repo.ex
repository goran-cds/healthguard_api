defmodule HealthguardApi.Repo do
  use Ecto.Repo,
    otp_app: :healthguard_api,
    adapter: Ecto.Adapters.Postgres
end
