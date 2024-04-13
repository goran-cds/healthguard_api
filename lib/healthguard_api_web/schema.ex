defmodule HealthguardApiWeb.Schema do
  use Absinthe.Schema

  alias HealthguardApiWeb.Resolvers

  import_types(HealthguardApiWeb.Schema.Types)

  query do
    @desc "Get a list of all users"
    field :users, list_of(:user_type) do
      resolve(&Resolvers.UserResolver.get_users/3)
    end
  end

  # mutation do
  # end
end
