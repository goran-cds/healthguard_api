defmodule HealthguardApiWeb.Schema.ProfileTypes do
  use Absinthe.Schema.Notation

  object :pacient_profile_type do
    field :id, :id
    field :cnp, :string
    field :age, :integer
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
  end

  input_object :medic_profile_input_type do
    field :badge_number, non_null(:string)
  end
end
