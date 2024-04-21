defmodule HealthguardApiWeb.Schema.UserType do
  use Absinthe.Schema.Notation

  import_types(HealthguardApiWeb.Schema.ProfileTypes)

  object :user_type do
    field :id, :id
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :phone_number, :string
    field :medic_profile, :medic_profile_type
    field :pacient_profile, :pacient_profile_type
  end

  input_object :pacient_user_input_type do
    field :email, non_null(:string)
    field :password, non_null(:string)
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :phone_number, non_null(:string)
    field :pacient_profile, :pacient_profile_input_type
    field :medic_email, non_null(:string)
  end

  input_object :medic_user_input_type do
    field :email, non_null(:string)
    field :password, non_null(:string)
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :phone_number, non_null(:string)
    field :medic_profile, :medic_profile_input_type
  end
end
