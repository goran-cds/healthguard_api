defmodule HealthguardApi.Users.Recommandation do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthguardApi.Users.ActivityType
  alias HealthguardApi.Users.Recommandation

  embedded_schema do
    field :recommandation, :string
    field :days_duration, :integer
    field :note, :string
    field :start_date, :date

    embeds_one :activity_type, ActivityType, on_replace: :delete
  end

  @doc false
  def changeset(%Recommandation{} = recommandation, attrs) do
    recommandation
    |> cast(attrs, [:recommandation, :days_duration, :note, :start_date])
    |> validate_required([:recommandation, :days_duration, :start_date])
  end
end
