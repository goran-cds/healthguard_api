defmodule HealthguardApiWeb.Resolvers.SessionResolver do
  alias HealthguardApi.Guardian
  alias HealthguardApi.Users

  def login_user(_, %{input: attrs}, _) do
    with {:ok, user} <- Users.authenticate_user(attrs),
         {:ok, jwt_token, _} <- Guardian.encode_and_sign(user) do
      {:ok, %{token: jwt_token, user: user}}
    end
  end
end