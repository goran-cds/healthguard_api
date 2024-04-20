defmodule HealthguardApi.Users.ActivityType do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthguardApi.Users.ActivityType

  @activity_types [
    :sedentary,
    :walking,
    :jogging,
    :running,
    :cycling
  ]

  def activity_types(), do: @activity_types

  embedded_schema do
    field :type, Ecto.Enum, values: @activity_types
  end

  @doc false
  def changeset(%ActivityType{} = activity_type, attrs) do
    activity_type
    |> cast(attrs, [:type])
    |> validate_required([:type])
    |> validate_inclusion(:type, @activity_types, message: "invalid activity type")
  end
end
