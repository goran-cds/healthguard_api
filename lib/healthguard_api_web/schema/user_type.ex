defmodule HealthguardApiWeb.Schema.UserType do
  use Absinthe.Schema.Notation

  import_types(HealthguardApiWeb.Schema.ProfileTypes)

  object :user_type do
    field :id, :id
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :phone_number, :string
    field :medic_profile, :medic_profile
    field :pacient_profile, :pacient_profile
  end
end
