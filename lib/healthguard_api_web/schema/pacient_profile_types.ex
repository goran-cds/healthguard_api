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

  object :sensor_data_type_for_day do
    field :bpm, list_of(:float)
    field :ecg, list_of(:float)
    field :temperature, list_of(:float)
    field :humidity, list_of(:float)
  end

  object :recommandation_type do
    field :days_duration, :integer
    field :recommandation, :string
    field :note, :string
    field :start_date, :date
    field :activity_type, :activity_type
  end

  object :health_warning_type do
    field :message, :string
    field :min_value, :float
    field :max_value, :float
    field :type, :sensor_type_enum
    field :activity_type, :activity_type
    field :defined_date, :date
    field :triggered_date, :date
    field :triggered, :boolean
  end

  object :activity_type do
    field :type, :activity_type_enum
  end

  object :pacient_current_activity_stats_type do
    field :type, :activity_type_enum
    field :end_date, :date
    field :completed_percentage, :integer
  end

  input_object :activity_type_input do
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

  input_object :add_recommandation_input_type do
    field :id, non_null(:id)
    field :recommandation, non_null(:string)
    field :start_date, non_null(:datetime)
    field :note, non_null(:string)
    field :days_duration, non_null(:integer)
    field :activity_type, non_null(:activity_type_input)
  end

  input_object :add_alert_input_type do
    field :id, non_null(:id)
    field :message, :string
    field :min_value, non_null(:float)
    field :max_value, non_null(:float)
    field :type, non_null(:sensor_type_enum)
    field :activity_type, non_null(:activity_type_input)
  end

  enum(:activity_type_enum, values: ActivityType.activity_types())
  enum(:sensor_type_enum, values: SensorData.sensor_types())
end
