defmodule HealthguardApiWeb.Schema do
  use Absinthe.Schema

  alias HealthguardApiWeb.Resolvers

  import_types(HealthguardApiWeb.Schema.Types)

  # add medic's email to pacient registration
  # add pacient :state in schema, values: [:pending, :confirmed]
  # create query to get last sensor data
  # create query to get last / ongoing activity
  # create a query to get all values from a specified sensor type

  query do
    @desc "Get a list of all users"
    field :users, list_of(:user_type) do
      resolve(&Resolvers.UserResolver.get_users/3)
    end

    @desc "Get a user's pacient id"
    field :get_pacient_id, :id do
      arg(:input, non_null(:id))
      resolve(&Resolvers.UserResolver.get_pacient_id/3)
    end

    @desc "Get a pacient's last read sensor data"
    field :get_pacient_last_sensor_data, :sensor_data_type do
      arg(:input, non_null(:id))
      resolve(&Resolvers.UserResolver.get_pacient_last_sensor_data/3)
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

    @desc "Log in user and return JWT token"
    field :login_user, type: :session_type do
      arg(:input, non_null(:session_input_type))
      resolve(&Resolvers.SessionResolver.login_user/3)
    end

    @desc "Add new sensor data for pacient"
    field :add_sensor_data_to_pacient, type: :user_type do
      arg(:input, non_null(:add_sensor_data_input_type))
      resolve(&Resolvers.UserResolver.add_sensor_data_to_pacient/3)
    end
  end
end
