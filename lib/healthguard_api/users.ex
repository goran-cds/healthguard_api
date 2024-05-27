defmodule HealthguardApi.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias HealthguardApi.Alerts.HealthWarnings
  alias HealthguardApi.Users.Recommandation
  alias HealthguardApi.Sensors.SensorData
  alias HealthguardApi.Users.PacientProfile
  alias HealthguardApi.Repo

  alias HealthguardApi.Users.{User, UserToken, UserNotifier, MedicProfile}

  ## Database getters

  @doc """
  Gets a user by email.
  """
  def get_user_by_email(email) when is_binary(email) do
    from(u in User, where: u.email == ^email)
    |> preload(medic_profile: [:pacients], pacient_profile: [:medic_profile])
    |> Repo.one()
    |> Repo.ok_error()
  end

  @doc """
  Gets a user by email and password.
  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user by id.
  """
  def get_user(id) do
    from(u in User, where: u.id == ^id)
    |> preload(medic_profile: [:pacients], pacient_profile: [:medic_profile])
    |> Repo.one()
    |> Repo.ok_error()
  end

  def get_pacient(id) do
    from(u in User, where: u.id == ^id)
    |> join(:left, [u], pp in PacientProfile, on: pp.user_id == u.id)
    |> join(:left, [u, pp], mp in MedicProfile, on: mp.id == pp.medic_profile_id)
    |> join(:left, [u, pp, mp], mu in User, on: mu.id == mp.user_id)
    |> select([u, pp, mp, mu], %{
      user: u,
      pacient_profile: pp,
      medic: mu
    })
    |> Repo.one()
    |> Repo.ok_error()
  end

  def get_user_by_pacient_id(pacient_profile_id) do
    User
    |> from(as: :user)
    |> join(:inner, [u], pp in PacientProfile, on: pp.user_id == u.id)
    |> where([u, pp], pp.id == ^pacient_profile_id)
    |> preload([:pacient_profile])
    |> Repo.one()
    |> Repo.ok_error()
  end

  def get_user_by_token(token) do
    user_token =
      from(ut in UserToken, where: ut.token == ^token)
      |> Repo.one()

    case user_token do
      nil ->
        {:error, :token_not_found}

      _ ->
        {:ok, user} = get_user(user_token.user_id)
        user
    end
  end

  def get_pacient_by_token(token) do
    user_token =
      from(ut in UserToken, where: ut.token == ^token)
      |> Repo.one()

    case user_token do
      nil ->
        {:error, :token_not_found}

      _ ->
        {:ok, user} = get_pacient(user_token.user_id)
        user
    end
  end

  def create_user_token(user_id, token) do
    %UserToken{user_id: user_id, token: token, context: "session"}
    |> Repo.insert()
  end

  ## User registration

  @doc """
  Registers a user.
  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(user, attrs) do
    user
    |> User.registered_changeset(attrs)
    |> Repo.update()
  end

  def update_pacient_profile(pacient_profile, attrs) do
    pacient_profile
    |> PacientProfile.changeset(attrs)
    |> Repo.update()
  end

  def get_users() do
    from(u in User)
    |> preload(medic_profile: [:pacients], pacient_profile: [:medic_profile])
    |> Repo.all()
  end

  def create_medic_profile(user, attrs \\ %{}) do
    %MedicProfile{user: user}
    |> MedicProfile.changeset(attrs)
    |> Repo.insert()
  end

  def create_pacient_profile(user, attrs \\ %{}) do
    %PacientProfile{user: user}
    |> PacientProfile.changeset(attrs)
    |> Repo.insert()
  end

  def get_pacient_profile(pacient_profile_id) do
    from(pp in PacientProfile, where: pp.id == ^pacient_profile_id)
    |> preload([:medic_profile])
    |> Repo.one()
    |> Repo.ok_error()
  end

  def get_medic_profile(medic_profile_id) do
    from(mp in MedicProfile, where: mp.id == ^medic_profile_id)
    |> Repo.one()
    |> Repo.ok_error()
  end

  def get_medic_pacients(user_id) do
    {:ok, user} =
      from(u in User, where: u.id == ^user_id)
      |> preload(medic_profile: [pacients: [:user]])
      |> Repo.one()
      |> Repo.ok_error()

    user.medic_profile.pacients
    |> Enum.map(fn pacient ->
      %{
        id: pacient.id,
        first_name: pacient.user.first_name,
        last_name: pacient.user.last_name,
        cnp: pacient.cnp,
        email: pacient.user.email,
        phone_number: pacient.user.phone_number,
        pacient_profile: pacient,
        inserted_at: pacient.inserted_at
      }
    end)
  end

  def associate_pacient_with_medic(pacient_profile_id, medic_profile) do
    with {:ok, pacient_profile} <- get_pacient_profile(pacient_profile_id),
         {:ok, updated_pacient_profile} <-
           pacient_profile
           |> PacientProfile.changeset(%{state: :confirmed})
           |> Ecto.Changeset.put_assoc(:medic_profile, medic_profile)
           |> Repo.update() do
      {:ok, updated_pacient_profile}
    end
  end

  def add_recommandation_to_pacient(pacient_profile_id, params) do
    attrs = %{
      recommandation: params.recommandation,
      days_duration: params.days_duration,
      note: params.note,
      start_date: params.start_date
    }

    add_recommandation = fn pacient_profile, recommandations ->
      new_recommandation =
        recommandations
        |> Enum.map(fn recommandation ->
          Recommandation.changeset(
            %Recommandation{activity_type: params.activity_type},
            recommandation
          )
        end)

      new_recommandation ++ pacient_profile.recommandations
    end

    recommandation_to_be_added = [
      attrs
    ]

    with {:ok, pacient_profile} <- get_pacient_profile(pacient_profile_id),
         recommandations <- add_recommandation.(pacient_profile, recommandation_to_be_added),
         {:ok, updated_pacient_profile} <-
           pacient_profile
           |> PacientProfile.changeset()
           |> Ecto.Changeset.put_embed(:recommandations, recommandations)
           |> Repo.update() do
      {:ok, updated_pacient_profile}
    end
  end

  def add_health_warning_to_pacient(pacient_profile_id, attrs) do
    add_health_warning = fn pacient_profile, health_warnings ->
      new_health_warning =
        health_warnings
        |> Enum.map(fn health_warning ->
          HealthWarnings.changeset(%HealthWarnings{}, health_warning)
        end)

      new_health_warning ++ pacient_profile.health_warnings
    end

    health_warning_to_be_added = [
      attrs
    ]

    with {:ok, pacient_profile} <- get_pacient_profile(pacient_profile_id),
         health_warnings <- add_health_warning.(pacient_profile, health_warning_to_be_added),
         {:ok, updated_pacient_profile} <-
           pacient_profile
           |> PacientProfile.changeset()
           |> Ecto.Changeset.put_embed(:health_warnings, health_warnings)
           |> Repo.update() do
      {:ok, updated_pacient_profile}
    end
  end

  def add_sensor_data_to_pacient(user_id, sensor_data_attrs) do
    temperature = %{
      type: :temperature,
      value: [sensor_data_attrs.temperature],
      date: DateTime.utc_now()
    }

    bpm = %{
      type: :bpm,
      value: [sensor_data_attrs.bpm],
      date: DateTime.utc_now()
    }

    humidity = %{
      type: :humidity,
      value: [sensor_data_attrs.humidity],
      date: DateTime.utc_now()
    }

    ecg = %{
      type: :ecg,
      value: sensor_data_attrs.ecg,
      date: DateTime.utc_now()
    }

    sensor_data = [bpm, ecg, temperature, humidity]

    add_sensor_data = fn pacient_profile, sensor_data ->
      new_data =
        sensor_data
        |> Enum.map(fn data ->
          SensorData.changeset(%SensorData{}, data)
        end)

      new_data ++ pacient_profile.sensor_data
    end

    with {:ok, user} <- get_user(user_id),
         {:ok, pacient_profile} <- get_pacient_profile(user.pacient_profile.id),
         sensor_data_list <- add_sensor_data.(pacient_profile, sensor_data),
         {:ok, updated_pacient_profile} <-
           pacient_profile
           |> PacientProfile.changeset()
           |> Ecto.Changeset.put_embed(:sensor_data, sensor_data_list)
           |> Repo.update() do
      {:ok, updated_pacient_profile}
    end
  end

  def get_pacient_sensor_data_by_type(pacient_profile_id, sensor_type) do
    from(pp in PacientProfile, where: pp.id == ^pacient_profile_id, select: pp.sensor_data)
    |> Repo.one()
    |> Enum.filter(fn sensor_data -> sensor_data.type == sensor_type end)
  end

  def get_pacient_sensor_data_by_date(pacient_profile_id, date) do
    check_if_date_matches = fn d ->
      d.year == date.year and
        d.month == date.month and
        d.day == date.day and
        d.hour == date.hour
    end

    sensor_data =
      from(pp in PacientProfile, where: pp.id == ^pacient_profile_id, select: pp.sensor_data)
      |> Repo.one()
      |> Enum.filter(fn sensor_data -> check_if_date_matches.(sensor_data.date) end)
      |> Enum.map(fn sensor_data ->
        %{
          type: sensor_data.type,
          value: sensor_data.value
        }
      end)

    bpm_data =
      sensor_data
      |> Enum.filter(fn data -> data.type == :bpm end)
      |> Enum.map(fn data -> data.value |> hd end)
      |> Enum.reverse()

    temperature_data =
      sensor_data
      |> Enum.filter(fn data -> data.type == :temperature end)
      |> Enum.map(fn data -> data.value |> hd end)
      |> Enum.reverse()

    humidity_data =
      sensor_data
      |> Enum.filter(fn data -> data.type == :humidity end)
      |> Enum.map(fn data -> data.value |> hd end)
      |> Enum.reverse()

    ecg_data =
      sensor_data
      |> Enum.filter(fn data -> data.type == :ecg end)
      |> Enum.map(fn data -> Enum.sum(data.value) / length(data.value) end)
      |> Enum.reverse()

    %{
      bpm: bpm_data,
      ecg: ecg_data,
      temperature: temperature_data,
      humidity: humidity_data
    }
  end

  def get_pacient_current_activity_stats(pacient_profile_id) do
    compute_end_date = fn start_date, days_duration ->
      Date.add(start_date, days_duration)
    end

    compute_completed_percentage = fn start_date, end_date ->
      current_date = Date.utc_today()

      total_days = Date.diff(end_date, start_date)
      passed_days = Date.diff(current_date, start_date)

      if total_days == 0 do
        100
      else
        trunc(passed_days / total_days * 100)
      end
    end

    pacient_data =
      from(pp in PacientProfile,
        where: pp.id == ^pacient_profile_id,
        select: %{
          recommandations: pp.recommandations,
          activity_type: pp.activity_type
        }
      )
      |> Repo.one()

    matching_recommandation =
      pacient_data.recommandations
      |> Enum.filter(fn data ->
        data.activity_type.type == pacient_data.activity_type.type
      end)
      |> hd

    end_date =
      compute_end_date.(matching_recommandation.start_date, matching_recommandation.days_duration)

    %{
      type: pacient_data.activity_type.type,
      end_date: end_date,
      completed_percentage:
        compute_completed_percentage.(matching_recommandation.start_date, end_date)
    }
  end

  def delete_user_by_pacient_profile_id(pacient_profile_id) do
    {:ok, deleted_pacient_profile} =
      from(pp in PacientProfile, where: pp.id == ^pacient_profile_id)
      |> Repo.one()
      |> Repo.delete()

    {:ok, _deleted_user} =
      from(u in User, where: u.id == ^deleted_pacient_profile.user_id)
      |> Repo.one()
      |> Repo.delete()
  end

  def get_pacient_last_read_sensor_data(pacient_profile_id) do
    from(pp in PacientProfile, where: pp.id == ^pacient_profile_id, select: pp.sensor_data)
    |> Repo.all()
    |> hd
  end

  def update_health_warning(pacient_profile, alert) do
    updated_health_warnings =
      pacient_profile.health_warnings
      |> Enum.map(fn health_warning ->
        if health_warning.id == alert.id do
          {:ok, updated_health_warning} =
            health_warning
            |> HealthWarnings.changeset(%{
              triggered: true,
              triggered_date: Date.utc_today()
            })
            |> Ecto.Changeset.apply_action(:create)

          updated_health_warning
          |> Map.from_struct()
          |> Map.put(:activity_type, %{type: updated_health_warning.activity_type.type})
        else
          health_warning
          |> Map.from_struct()
          |> Map.put(:activity_type, %{type: health_warning.activity_type.type})
        end
      end)

    update_pacient_profile(pacient_profile, %{health_warnings: updated_health_warnings})
  end

  def maybe_trigger_alert(pacient_profile, sensor_data) do
    processed_data = %{
      bpm: sensor_data[:bpm],
      temperature: sensor_data[:temperature],
      humidity: sensor_data[:humidity],
      ecg: Enum.sum(sensor_data[:ecg]) / length(sensor_data[:ecg])
    }

    triggered_alerts =
      pacient_profile.health_warnings
      |> Enum.filter(fn warning ->
        value = processed_data[warning.type]

        warning.triggered == false and
          pacient_profile.activity_type.type == warning.activity_type.type and
          (value < warning.min_value or value > warning.max_value)
      end)

    case triggered_alerts do
      [] ->
        {:ok, :normal}

      alerts ->
        alerts
        |> Enum.map(fn alert ->
          {:ok, _updated_pacient_profile} = update_health_warning(pacient_profile, alert)
        end)

        {:ok, :triggered}
    end
  end

  # -------------------------------------------------------------------------------------------------------------------------------------------------

  def authenticate_user(attrs) do
    {:ok, user} = get_user_by_email(attrs.email)

    case Argon2.verify_pass(attrs.password, user.hashed_password) do
      true ->
        {:ok, user}

      false ->
        {:error, :invalid_credentials}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.
  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.
  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.
  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.
  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.
  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.
  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.
  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.
  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.
  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  # Helper functions

  def calculate_age(cnp) when is_binary(cnp) and byte_size(cnp) == 13 do
    {birth_date, century} = extract_birth_date_and_century(cnp)
    calculate_age_from_birth_date(birth_date, century)
  end

  defp extract_birth_date_and_century(
         <<first_digit::binary-size(1), year::binary-size(2), month::binary-size(2),
           day::binary-size(2), _rest::binary>>
       ) do
    year = String.to_integer(year)
    month = String.to_integer(month)
    day = String.to_integer(day)

    century =
      case first_digit do
        "1" -> 1900
        "2" -> 1900
        "3" -> 1800
        "4" -> 1800
        "5" -> 2000
        "6" -> 2000
        _ -> raise ArgumentError, "Invalid CNP first digit"
      end

    {{year, month, day}, century}
  end

  defp calculate_age_from_birth_date({year, month, day}, century) do
    birth_date = Date.new!(century + year, month, day)
    current_date = Date.utc_today()

    years_diff = current_date.year - birth_date.year

    if Date.compare(Date.new!(current_date.year, birth_date.month, birth_date.day), current_date) in [
         :gt
       ] do
      years_diff - 1
    else
      years_diff
    end
  end
end
