defmodule HealthguardApiWeb.Schema.PacientProfileTypes do
  use Absinthe.Schema.Notation

  alias HealthguardApi.Sensors.SensorData
  alias HealthguardApi.Users.ActivityType

  import_types(Absinthe.Type.Custom)

  object :address_type do
    field :country, :string
    field :city, :string
    field :street, :string
    field :street_number, :integer
  end

  object :sensor_data_type do
    field :type, :sensor_type_enum
    field :value, list_of(:float)
    field :date, :datetime
  end

  object :recommandation_type do
    field :days_duration, :integer
    field :note, :string
    field :start_date, :date
    field :activity_type, :activity_type
  end

  object :activity_type do
    field :type, :activity_type_enum
  end

  input_object :address_input_type do
    field :country, non_null(:string)
    field :city, non_null(:string)
    field :street, non_null(:string)
    field :street_number, non_null(:integer)
  end

  input_object :sensor_data_input_type do
    field :type, non_null(:sensor_type_enum)
    field :value, non_null(:float)
    field :date, non_null(:datetime)
  end

  enum(:activity_type_enum, values: ActivityType.activity_types())
  enum(:sensor_type_enum, values: SensorData.sensor_types())
end
