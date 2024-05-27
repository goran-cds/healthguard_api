defmodule HealthguardApiWeb.Resolvers.UserResolver do
  alias HealthguardApi.Users
  alias HealthguardApi.Guardian

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

  def get_pacient_by_token(_, %{token: token}, _) do
    {:ok, Users.get_pacient_by_token(token)}
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

  def get_pacient_last_sensor_data(_, %{pacient_id: pacient_id, sensor_type: sensor_type}, _) do
    {:ok, user} = Users.get_user_by_pacient_id(pacient_id)

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

  def get_pacient_last_read_sensor_data(_, %{pacient_id: pacient_id}, _) do
    {:ok, user} = Users.get_user_by_pacient_id(pacient_id)

    case user.pacient_profile do
      nil ->
        {:ok, nil}

      _ ->
        if user.pacient_profile.sensor_data == [],
          do: {:ok, nil},
          else:
            {:ok,
             Users.get_pacient_last_read_sensor_data(user.pacient_profile.id) |> Enum.take(4)}
    end
  end

  def get_pacient_last_read_sensor_data_by_token(_, %{token: token}, _) do
    user = Users.get_user_by_token(token)

    case user.pacient_profile do
      nil ->
        {:ok, nil}

      _ ->
        if user.pacient_profile.sensor_data == [],
          do: {:ok, nil},
          else:
            {:ok,
             Users.get_pacient_last_read_sensor_data(user.pacient_profile.id) |> Enum.take(4)}
    end
  end

  def get_pacient_sensor_data_by_type(_, %{pacient_id: pacient_id, sensor_type: sensor_type}, _) do
    {:ok, user} = Users.get_user_by_pacient_id(pacient_id)

    case user.pacient_profile do
      nil ->
        {:ok, nil}

      _ ->
        {:ok, Users.get_pacient_sensor_data_by_type(user.pacient_profile.id, sensor_type)}
    end
  end

  def get_pacient_sensor_data_by_date(_, %{token: token, date: date}, _) do
    user = Users.get_user_by_token(token)

    case user.pacient_profile do
      nil ->
        {:ok, nil}

      _ ->
        if user.pacient_profile.sensor_data == [],
          do: {:ok, nil},
          else: {:ok, Users.get_pacient_sensor_data_by_date(user.pacient_profile.id, date)}
    end
  end

  def get_pacient_current_activity_stats(_, %{token: token}, _) do
    user = Users.get_user_by_token(token)

    case user.pacient_profile do
      nil ->
        {:ok, nil}

      _ ->
        if user.pacient_profile.sensor_data == [],
          do: {:ok, nil},
          else: {:ok, Users.get_pacient_current_activity_stats(user.pacient_profile.id)}
    end
  end

  def register_pacient(_, %{input: attrs}, _) do
    user_params = %{
      email: attrs.email,
      password: attrs.password,
      first_name: attrs.first_name,
      last_name: attrs.last_name
    }

    age = Users.calculate_age(attrs.pacient_profile.cnp)

    pacient_params = %{
      cnp: attrs.pacient_profile.cnp,
      age: age
    }

    medic_email = attrs.medic_email

    with {:ok, medic_user} <-
           Users.get_user_by_email(medic_email),
         {:ok, user} <- Users.create_user(user_params),
         {:ok, pacient_profile} <-
           Users.create_pacient_profile(user, pacient_params),
         {:ok, medic_profile} <-
           Users.get_medic_profile(medic_user.medic_profile.id),
         {:ok, _} <-
           Users.associate_pacient_with_medic(pacient_profile.id, medic_profile) do
      Users.get_user(user.id)
    else
      {:error, msg} ->
        {:error, msg}
    end
  end

  def register_pacient_by_medic(_, %{input: attrs}, _) do
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
      profession: attrs.pacient_profile.profession,
      work_place: attrs.pacient_profile.work_place,
      address: %{
        country: attrs.pacient_profile.address.country,
        city: attrs.pacient_profile.address.city,
        street: attrs.pacient_profile.address.street,
        street_number: attrs.pacient_profile.address.street_number
      }
    }

    medic_email = attrs.medic_email

    with {:ok, medic_user} <-
           Users.get_user_by_email(medic_email),
         {:ok, user} <- Users.create_user(user_params),
         {:ok, pacient_profile} <-
           Users.create_pacient_profile(user, pacient_params),
         {:ok, medic_profile} <-
           Users.get_medic_profile(medic_user.medic_profile.id),
         {:ok, _} <-
           Users.associate_pacient_with_medic(pacient_profile.id, medic_profile),
         {:ok, user} <- Users.authenticate_user(attrs),
         {:ok, jwt_token, _} <- Guardian.encode_and_sign(user) do
      Users.create_user_token(user.id, jwt_token)
      {:ok, user} = Users.get_user(user.id)
      {:ok, %{token: jwt_token, user: user}}
    else
      {:error, msg} ->
        {:error, msg}
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

    with {:ok, pacient_profile} <- Users.add_sensor_data_to_pacient(user_id, sensor_data),
         {:ok, _message} <-
           Users.maybe_trigger_alert(pacient_profile, sensor_data) do
      Users.get_user(pacient_profile.user_id)
    end
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

  def add_alert_to_pacient(_, %{input: attrs}, _) do
    pacient_profile_id = attrs.id

    message =
      case Map.has_key?(attrs, :message) do
        false -> nil
        true -> attrs.message
      end

    health_warning = %{
      type: attrs.type,
      message: message,
      min_value: attrs.min_value,
      max_value: attrs.max_value,
      activity_type: %{
        type: attrs.activity_type.type
      },
      defined_date: Date.utc_today()
    }

    {:ok, pacient_profile} =
      Users.add_health_warning_to_pacient(pacient_profile_id, health_warning)

    Users.get_user(pacient_profile.user_id)
  end

  def delete_pacient_user(_, %{pacient_id: pacient_id}, _) do
    {:ok, _user} = Users.delete_user_by_pacient_profile_id(pacient_id)
    {:ok, "Successfully deleted"}
  end

  def update_pacient_user(_, %{input: input}, _) do
    pacient_profile_id = input.pacient_id

    user_attrs = %{
      email: input.email,
      first_name: input.first_name,
      last_name: input.last_name,
      phone_number: input.phone_number
    }

    pacient_profile_attrs = %{
      age: input.age,
      work_place: input.work_place,
      profession: input.profession,
      address: %{
        country: input.country,
        city: input.city,
        street: input.street,
        street_number: input.street_number
      }
    }

    with {:ok, user} <- Users.get_user_by_pacient_id(pacient_profile_id),
         {:ok, pacient_profile} <- Users.get_pacient_profile(pacient_profile_id),
         {:ok, _updated_user} <- Users.update_user(user, user_attrs),
         {:ok, updated_pacient_profile} <-
           Users.update_pacient_profile(pacient_profile, pacient_profile_attrs) do
      Users.get_user(updated_pacient_profile.user_id)
    end
  end

  def update_pacient_activity_type(
        _,
        %{pacient_id: pacient_profile_id, activity_type: activity_type},
        _
      ) do
    with {:ok, pacient_profile} <- Users.get_pacient_profile(pacient_profile_id),
         {:ok, updated_pacient_profile} <-
           Users.update_pacient_profile(pacient_profile, %{
             activity_type: %{type: activity_type.type}
           }) do
      Users.get_user(updated_pacient_profile.user_id)
    end
  end
end
