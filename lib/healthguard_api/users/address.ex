defmodule HealthguardApi.Users.Address do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthguardApi.Users.Address

  embedded_schema do
    field :country, :string
    field :city, :string
    field :street, :string
    field :street_number, :integer
  end

  @doc false
  def changeset(%Address{} = address, attrs) do
    address
    |> cast(attrs, [:country, :city, :street, :street_number])
    |> validate_required([:country, :city, :street, :street_number])
    |> validate_length(:country, max: 100, message: "must be less than 100 characters")
    |> validate_length(:city, max: 100, message: "must be less than 100 characters")
    |> validate_length(:street, max: 100, message: "must be less than 100 characters")
  end
end
