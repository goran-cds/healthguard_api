defmodule HealthguardApi.Alerts.HealthWarnings do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthguardApi.Users.ActivityType
  alias HealthguardApi.Alerts.HealthWarnings

  embedded_schema do
    field :message, :string
    field :min_value, :float
    field :max_value, :float

    embeds_one :activity_type, ActivityType, on_replace: :delete
  end

  @doc false
  def changeset(%HealthWarnings{} = health_warnings, attrs) do
    health_warnings
    |> cast(attrs, [])
    |> validate_required([])
  end
end
