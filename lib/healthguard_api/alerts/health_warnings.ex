defmodule HealthguardApi.Alerts.HealthWarnings do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthguardApi.Sensors.SensorData
  alias HealthguardApi.Users.ActivityType
  alias HealthguardApi.Alerts.HealthWarnings

  embedded_schema do
    field :message, :string
    field :type, Ecto.Enum, values: SensorData.sensor_types()
    field :min_value, :float
    field :max_value, :float
    field :triggered, :boolean, default: false
    field :defined_date, :date
    field :triggered_date, :date

    embeds_one :activity_type, ActivityType, on_replace: :delete
  end

  @doc false
  def changeset(%HealthWarnings{} = health_warnings, attrs) do
    health_warnings
    |> cast(attrs, [
      :type,
      :message,
      :min_value,
      :max_value,
      :triggered,
      :defined_date,
      :triggered_date
    ])
    |> cast_embed(:activity_type, with: &ActivityType.changeset/2)
    |> validate_required([:type, :min_value, :max_value, :activity_type, :defined_date])
  end
end
