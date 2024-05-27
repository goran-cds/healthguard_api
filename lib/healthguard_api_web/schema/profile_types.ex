defmodule HealthguardApiWeb.Schema.ProfileTypes do
  use Absinthe.Schema.Notation

  import_types(HealthguardApiWeb.Schema.PacientProfileTypes)
  # import_types(HealthguardApiWeb.Schema.UserType)

  alias HealthguardApi.Users.PacientProfile

  object :pacient_profile_type do
    field :id, :id
    field :cnp, :string
    field :age, :integer
    field :address, :address_type
    field :work_place, :string
    field :profession, :string
    field :state, :state_type_enum
    field :sensor_data, list_of(:sensor_data_type)
    field :recommandations, list_of(:recommandation_type)
    field :health_warnings, list_of(:health_warning_type)
    field :activity_type, :activity_type
    field :medic_profile, :medic_profile_type
    field :inserted_at, :date
    field :user_id, :id
  end

  object :pacient_user_type do
    field :user, :user_type
    field :pacient_profile, :pacient_profile_type
    field :medic, :user_type
  end

  object :pacient_data_type do
    field :id, :id
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :cnp, :string
    field :inserted_at, :string
    field :phone_number, :string
    field :pacient_profile, :pacient_profile_type
  end

  object :medic_profile_type do
    field :id, :id
    field :badge_number, :string
    field :pacients, list_of(:pacient_profile_type)
  end

  input_object :pacient_profile_input_type do
    field :cnp, non_null(:string)
  end

  input_object :pacient_profile_input_type_extended do
    field :age, non_null(:integer)
    field :cnp, non_null(:string)
    field :work_place, non_null(:string)
    field :profession, non_null(:string)
    field :address, non_null(:address_input_type)
  end

  input_object :medic_profile_input_type do
    field :badge_number, non_null(:string)
  end

  input_object :add_sensor_data_input_type do
    field :user_id, :id
    field :temperature, :float
    field :bpm, :float
    field :humidity, :float
    field :ecg, list_of(:float)
  end

  input_object :update_pacient_user_input_type do
    field :pacient_id, :id
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :phone_number, :string
    field :age, :integer
    field :work_place, :string
    field :profession, :string
    field :country, :string
    field :city, :string
    field :street, :string
    field :street_number, :integer
  end

  enum(:state_type_enum, values: PacientProfile.pacient_states())
end
