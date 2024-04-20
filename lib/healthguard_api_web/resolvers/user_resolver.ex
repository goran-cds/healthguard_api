defmodule HealthguardApiWeb.Resolvers.UserResolver do
  alias HealthguardApi.Users

  def get_users(_, _, %{context: context}) do
    IO.inspect(context)
    {:ok, Users.get_users()}
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
      age: attrs.pacient_profile.age
    }

    {:ok, user} = Users.create_user(user_params)
    {:ok, _pacient_profile} = Users.create_pacient_profile(user, pacient_params)

    {:ok, Users.get_user(user.id)}
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

    {:ok, Users.get_user(user.id)}
  end
end
