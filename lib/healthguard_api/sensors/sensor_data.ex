defmodule HealthguardApi.Sensors.SensorData do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthguardApi.Users.ActivityType
  alias HealthguardApi.Sensors.SensorData

  @sensor_types [
    :temperature,
    :humidity,
    :bpm
  ]

  embedded_schema do
    field :type, Ecto.Enum, values: @sensor_types
    field :value, :float
    field :date, :date

    embeds_one :activity_type, ActivityType, on_replace: :delete
  end

  @doc false
  def changeset(%SensorData{} = sensor_data, attrs) do
    sensor_data
    |> cast(attrs, [:type, :value, :date])
    |> validate_required([:type, :value, :date])
    |> validate_inclusion(:type, @sensor_types, message: "invalid sensor type")
  end
end
