defmodule HealthguardApi.Users.PacientProfile do
  use Ecto.Schema
  import Ecto.Changeset

  alias HealthguardApi.Users.MedicProfile
  alias HealthguardApi.Sensors.SensorData
  alias HealthguardApi.Users.{User, Address, Recommandation, ActivityType}

  @pacient_states [
    :pending,
    :confirmed
  ]

  def pacient_states(), do: @pacient_states

  schema "pacient_profiles" do
    field :cnp, :string
    field :age, :integer
    field :profession, :string
    field :work_place, :string
    field :allergies, {:array, :string}, default: []

    field :state, Ecto.Enum, values: @pacient_states, default: :pending

    embeds_one :address, Address, on_replace: :delete
    embeds_many :sensor_data, SensorData, on_replace: :delete
    embeds_many :recommandations, Recommandation, on_replace: :delete
    embeds_one :activity_type, ActivityType, on_replace: :delete

    belongs_to :user, User
    belongs_to :medic_profile, MedicProfile

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(pacient_profile, attrs \\ %{}) do
    pacient_profile
    |> cast(attrs, [:cnp, :age, :profession, :work_place, :allergies, :state])
    |> cast_assoc(:user)
    |> cast_assoc(:medic_profile)
    |> cast_embed(:address, with: &Address.changeset/2)
    |> cast_embed(:sensor_data, with: &SensorData.changeset/2)
    |> cast_embed(:recommandations, with: &Recommandation.changeset/2)
    |> cast_embed(:activity_type, with: &ActivityType.changeset/2)
    |> validate_required([
      :cnp,
      :age,
      :state
    ])
    |> validate_length(:cnp, is: 13, message: "invalid cnp")
    |> validate_inclusion(:state, @pacient_states)
  end
end
