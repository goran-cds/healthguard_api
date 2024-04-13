defmodule HealthguardApiWeb.Schema.ProfileTypes do
  use Absinthe.Schema.Notation

  object :pacient_profile do
    field :id, :id
    field :cnp, :string
    field :age, :integer
    field :medic_profile, :medic_profile
  end

  object :medic_profile do
    field :id, :id
    field :badge_number, :string
    field :pacients, list_of(:pacient_profile)
  end
end
