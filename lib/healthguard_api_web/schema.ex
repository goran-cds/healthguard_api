defmodule HealthguardApiWeb.Schema do
  use Absinthe.Schema

  alias HealthguardApiWeb.Resolvers

  import_types(HealthguardApiWeb.Schema.Types)

  query do
    @desc "Get a list of all users"
    field :users, list_of(:user_type) do
      resolve(&Resolvers.UserResolver.get_users/3)
    end

    @desc "Get a user by id"
    field :get_user, :user_type do
      arg(:id, non_null(:id))
      resolve(&Resolvers.UserResolver.get_user_by_id/3)
    end

    @desc "Get a user by pacient id"
    field :get_user_by_pacient_id, :user_type do
      arg(:id, non_null(:id))
      resolve(&Resolvers.UserResolver.get_user_by_pacient_id/3)
    end

    @desc "Get a user by session token"
    field :get_user_by_token, :user_type do
      arg(:token, non_null(:string))
      resolve(&Resolvers.UserResolver.get_user_by_token/3)
    end

    @desc "Get a pacient by session token"
    field :get_pacient_by_token, :pacient_user_type do
      arg(:token, non_null(:string))
      resolve(&Resolvers.UserResolver.get_pacient_by_token/3)
    end

    @desc "Get a user's pacient id"
    field :get_pacient_id, :id do
      arg(:user_id, non_null(:id))
      resolve(&Resolvers.UserResolver.get_pacient_id/3)
    end

    @desc "Get a medic's pacients data"
    field :get_medic_pacients, list_of(:pacient_data_type) do
      arg(:user_id, :id)
      resolve(&Resolvers.UserResolver.get_medic_pacients/3)
    end

    @desc "Get a pacient's last read sensor data for a type"
    field :get_pacient_last_sensor_data_by_type, :sensor_data_type do
      arg(:pacient_id, non_null(:id))
      arg(:sensor_type, non_null(:sensor_type_enum))
      resolve(&Resolvers.UserResolver.get_pacient_last_sensor_data/3)
    end

    @desc "Get a pacient's last read sensor data (all sensors)"
    field :get_pacient_last_read_sensor_data, list_of(:sensor_data_type) do
      arg(:pacient_id, non_null(:id))
      resolve(&Resolvers.UserResolver.get_pacient_last_read_sensor_data/3)
    end

    @desc "Get a pacient's last read sensor data (all sensors) by token"
    field :get_pacient_last_read_sensor_data_by_token, list_of(:sensor_data_type) do
      arg(:token, non_null(:string))
      resolve(&Resolvers.UserResolver.get_pacient_last_read_sensor_data_by_token/3)
    end

    @desc "Get a pacient's sensor data by type"
    field :get_pacient_sensor_data_by_type, list_of(:sensor_data_type) do
      arg(:user_id, non_null(:id))
      arg(:sensor_type, non_null(:sensor_type_enum))
      resolve(&Resolvers.UserResolver.get_pacient_sensor_data_by_type/3)
    end
  end

  mutation do
    @desc "Register a pacient user"
    field :register_pacient, type: :session_type do
      arg(:input, non_null(:pacient_user_input_type))
      resolve(&Resolvers.UserResolver.register_pacient/3)
    end

    @desc "Register a pacient user with all parameters (by doctor)"
    field :register_pacient_by_medic, type: :user_type do
      arg(:input, non_null(:pacient_user_input_type_extended))
      resolve(&Resolvers.UserResolver.register_pacient_by_medic/3)
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

    @desc "Log out user and delete JWT token"
    field :logout_user, type: :session_delete_type do
      arg(:input, non_null(:session_delete_input_type))
      resolve(&Resolvers.SessionResolver.logout_user/3)
    end

    @desc "Add new sensor data for pacient"
    field :add_sensor_data_to_pacient, type: :user_type do
      arg(:input, non_null(:add_sensor_data_input_type))
      resolve(&Resolvers.UserResolver.add_sensor_data_to_pacient/3)
    end

    @desc "Delete a pacient user"
    field :delete_pacient_user, type: :string do
      arg(:pacient_id, non_null(:id))
      resolve(&Resolvers.UserResolver.delete_pacient_user/3)
    end

    @desc "Add a recommandation to a pacient user"
    field :add_recommandation, type: :user_type do
      arg(:input, non_null(:add_recommandation_input_type))
      resolve(&Resolvers.UserResolver.add_recommandation_to_pacient/3)
    end

    @desc "Update a user by pacient id"
    field :update_pacient_user, type: :user_type do
      arg(:input, non_null(:update_pacient_user_input_type))
      resolve(&Resolvers.UserResolver.update_pacient_user/3)
    end

    @desc "Add a new alert for a pacient user"
    field :add_alert, type: :user_type do
      arg(:input, non_null(:add_alert_input_type))
      resolve(&Resolvers.UserResolver.add_alert_to_pacient/3)
    end

    @desc "Update a pacient's current activity"
    field :update_pacient_activity_type, :user_type do
      arg(:pacient_id, non_null(:id))
      arg(:activity_type, non_null(:activity_type_input))
      resolve(&Resolvers.UserResolver.update_pacient_activity_type/3)
    end
  end
end
