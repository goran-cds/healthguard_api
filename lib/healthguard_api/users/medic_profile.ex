defmodule HealthguardApi.Users.MedicProfile do
  use Ecto.Schema
  import Ecto.Changeset

  alias HealthguardApi.Users.PacientProfile
  alias HealthguardApi.Users.User

  schema "medic_profiles" do
    field :badge_number, :string

    has_many :pacients, PacientProfile

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(medic_profile, attrs \\ %{}) do
    medic_profile
    |> cast(attrs, [:badge_number])
    |> cast_assoc(:user)
    |> validate_required([:badge_number])
    |> validate_length(:badge_number, max: 8)
  end
end
