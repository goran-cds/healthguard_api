defmodule HealthguardApi.Repo.Migrations.CreatePacientProfiles do
  use Ecto.Migration

  def change do
    create table(:pacient_profiles) do
      add :cnp, :string, null: false
      add :age, :integer, null: false
      add :profession, :string
      add :work_place, :string
      add :allergies, {:array, :string}, default: []

      add :address, :jsonb, null: false
      add :sensor_data, :jsonb, null: false, default: "[]"
      add :recommandations, :jsonb, null: false, default: "[]"
      add :activity_type, :jsonb, null: false

      add :user_id, references(:users), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
