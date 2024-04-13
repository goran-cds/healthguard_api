defmodule HealthguardApiWeb.Resolvers.UserResolver do
  alias HealthguardApi.Users

  def users(_, _, _) do
    {:ok, Users.get_users()}
  end
end
