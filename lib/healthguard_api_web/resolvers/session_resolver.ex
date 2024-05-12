defmodule HealthguardApiWeb.Resolvers.SessionResolver do
  alias HealthguardApi.Guardian
  alias HealthguardApi.Users

  def login_user(_, %{input: attrs}, _) do
    with {:ok, user} <- Users.authenticate_user(attrs),
         {:ok, jwt_token, _} <- Guardian.encode_and_sign(user) do
      Users.create_user_token(user.id, jwt_token)
      {:ok, %{token: jwt_token, user: user}}
    end
  end

  def logout_user(_, %{input: attrs}, _) do
    :ok = Users.delete_user_session_token(attrs.token)
    {:ok, %{token: attrs.token}}
  end
end
