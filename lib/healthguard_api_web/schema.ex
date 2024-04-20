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

  mutation do
    @desc "Register a pacient user"
    field :register_pacient, type: :user_type do
      arg(:input, non_null(:pacient_user_input_type))
      resolve(&Resolvers.UserResolver.register_pacient/3)
    end

    @desc "Register a medic user"
    field :register_medic, type: :user_type do
      arg(:input, non_null(:medic_user_input_type))
      resolve(&Resolvers.UserResolver.register_medic/3)
    end
  end
end
