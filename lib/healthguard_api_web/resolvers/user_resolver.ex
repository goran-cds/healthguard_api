defmodule HealthguardApiWeb.Resolvers.UserResolver do
  alias HealthguardApi.Users

  def get_users(_, _, _) do
    {:ok, Users.get_users()}
  end

  def get_pacient_id(_, %{input: user_id}, _) do
    {:ok, user} = Users.get_user(user_id)

    case user.pacient_profile do
      nil ->
        {:ok, nil}

      _ ->
        {:ok, user.pacient_profile.id}
    end
  end

  def get_pacient_last_sensor_data(_, %{user_id: user_id, sensor_type: sensor_type}, _) do
    {:ok, user} = Users.get_user(user_id)

    case user.pacient_profile do
      nil ->
        {:ok, nil}

      _ ->
        if user.pacient_profile.sensor_data == [],
          do: {:ok, nil},
          else:
            {:ok,
             Users.get_pacient_sensor_data_by_type(user.pacient_profile.id, sensor_type) |> hd}
    end
  end

  def get_pacient_sensor_data_by_type(_, %{user_id: user_id, sensor_type: sensor_type}, _) do
    {:ok, user} = Users.get_user(user_id)

    case user.pacient_profile do
      nil ->
        {:ok, nil}

      _ ->
        {:ok, Users.get_pacient_sensor_data_by_type(user.pacient_profile.id, sensor_type)}
    end
  end

  def register_pacient(_, %{input: attrs}, _) do
    user_params = %{
      email: attrs.email,
      password: attrs.password,
      first_name: attrs.first_name,
      last_name: attrs.last_name,
      phone_number: attrs.phone_number
    }

    pacient_params = %{
      cnp: attrs.pacient_profile.cnp,
      age: attrs.pacient_profile.age,
      address: attrs.pacient_profile.address
    }

    {:ok, user} = Users.create_user(user_params)
    {:ok, _pacient_profile} = Users.create_pacient_profile(user, pacient_params)

    Users.get_user(user.id)
  end

  def register_medic(_, %{input: attrs}, _) do
    user_params = %{
      email: attrs.email,
      password: attrs.password,
      first_name: attrs.first_name,
      last_name: attrs.last_name,
      phone_number: attrs.phone_number
    }

    medic_params = %{
      badge_number: attrs.medic_profile.badge_number
    }

    {:ok, user} = Users.create_user(user_params)
    {:ok, _medic_profile} = Users.create_medic_profile(user, medic_params)

    Users.get_user(user.id)
  end

  def add_sensor_data_to_pacient(_, %{input: attrs}, _) do
    pacient_id = attrs.pacient_id
    sensor_data = attrs.sensor_data

    {:ok, pacient_profile} = Users.add_sensor_data_to_pacient(pacient_id, sensor_data)

    Users.get_user(pacient_profile.user_id)
  end
end
