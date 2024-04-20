defmodule HealthguardApiWeb.Schema.ProfileTypes do
  use Absinthe.Schema.Notation

  import_types(HealthguardApiWeb.Schema.PacientProfileTypes)

  object :pacient_profile_type do
    field :id, :id
    field :cnp, :string
    field :age, :integer
    field :address, :address_type
    field :sensor_data, list_of(:sensor_data_type)
    field :recommandations, list_of(:recommandation_type)
    field :activity_type, :activity_type
    field :medic_profile, :medic_profile_type
  end

  object :medic_profile_type do
    field :id, :id
    field :badge_number, :string
    field :pacients, list_of(:pacient_profile_type)
  end

  input_object :pacient_profile_input_type do
    field :cnp, non_null(:string)
    field :age, non_null(:integer)
    field :address, :address_input_type
  end

  input_object :medic_profile_input_type do
    field :badge_number, non_null(:string)
  end

  input_object :add_sensor_data_input_type do
    field :pacient_id, :id
    field :sensor_data, :sensor_data_input_type
  end
end
