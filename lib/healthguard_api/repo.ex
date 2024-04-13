defmodule HealthguardApi.Repo do
  use Ecto.Repo,
    otp_app: :healthguard_api,
    adapter: Ecto.Adapters.Postgres

  @spec ok_error(struct() | nil) :: {:ok, struct()} | {:error, :not_found}
  def ok_error(t) do
    case t do
      nil -> {:error, :not_found}
      obj -> {:ok, obj}
    end
  end
end
