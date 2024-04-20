defmodule HealthguardApi.Guardian do
  alias HealthguardApi.Users
  use Guardian, otp_app: :healthguard_api

  def subject_for_token(%{id: id} = _user, _claims) do
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :sub_not_provided}
  end

  def resource_from_claims(%{"sub" => id} = _claims) do
    case Users.get_user(id) do
      {:error, :not_found} ->
        {:error, :resource_not_found}

      {:ok, user} ->
        {:ok, user}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :sub_not_provided}
  end
end
