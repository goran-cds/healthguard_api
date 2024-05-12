defmodule HealthguardApiWeb.Resolvers.UserResolver do
  alias HealthguardApi.Users

  def get_users(_, _, _) do
    {:ok, Users.get_users()}
  end

  def get_user_by_id(_, %{id: id}, _) do
    {:ok, user} = Users.get_user(id)
    {:ok, user}
  end

  def get_user_by_pacient_id(_, %{id: id}, _) do
    {:ok, user} = Users.get_user_by_pacient_id(id)
    {:ok, user}
  end

  def get_user_by_token(_, %{token: token}, _) do
    {:ok, Users.get_user_by_token(token)}
  end

  def get_medic_pacients(_, %{user_id: user_id}, _) do
    {:ok, Users.get_medic_pacients(user_id)}
  end

  def get_pacient_id(_, %{user_id: user_id}, _) do
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
      address: attrs.pacient_profile.address,
      work_place: attrs.pacient_profile.work_place,
      profession: attrs.pacient_profile.profession
    }

    medic_email = attrs.medic_email

    with {:ok, user} <- Users.create_user(user_params),
         {:ok, pacient_profile} <-
           Users.create_pacient_profile(user, pacient_params),
         {:ok, medic_user} <-
           Users.get_user_by_email(medic_email),
         {:ok, medic_profile} <-
           Users.get_medic_profile(medic_user.medic_profile.id),
         {:ok, _} <-
           Users.associate_pacient_with_medic(pacient_profile.id, medic_profile) do
      Users.get_user(user.id)
    end
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
    user_id = attrs.user_id

    sensor_data = %{
      bpm: attrs.bpm,
      ecg: attrs.ecg,
      temperature: attrs.temperature,
      humidity: attrs.humidity
    }

    {:ok, pacient_profile} = Users.add_sensor_data_to_pacient(user_id, sensor_data)

    Users.get_user(pacient_profile.user_id)
  end

  def add_recommandation_to_pacient(_, %{input: attrs}, _) do
    pacient_profile_id = attrs.id

    recommandation = %{
      recommandation: attrs.recommandation,
      start_date: attrs.start_date,
      note: attrs.note,
      days_duration: attrs.days_duration
    }

    {:ok, pacient_profile} =
      Users.add_recommandation_to_pacient(pacient_profile_id, recommandation)

    Users.get_user(pacient_profile.user_id)
  end

  def delete_pacient_user(_, %{pacient_id: pacient_id}, _) do
    {:ok, _user} = Users.delete_user_by_pacient_profile_id(pacient_id)
    {:ok, "Successfully deleted"}
  end
end
