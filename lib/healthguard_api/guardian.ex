defmodule HealthguardApi.Guardian do
  alias HealthguardApi.Users
  use Guardian, otp_app: :healthguard_api

  def subject_for_token(%{id: id} = _user, _claims) do
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :user_not_provided}
  end

  def resource_from_claims(%{"sub" => id} = _claims) do
    {:ok, _user} = Users.get_user(id)
  end

  def resource_from_claims(_claims) do
    {:error, :subject_not_provided}
  end
end
