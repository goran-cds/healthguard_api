defmodule HealthguardApi.Repo.Migrations.CreatePacientProfiles do
  use Ecto.Migration

  def change do
    create table(:pacient_profiles) do
      add :cnp, :string, null: false
      add :age, :integer, null: false
      add :profession, :string
      add :work_place, :string
      add :allergies, {:array, :string}, default: []

      add :state, :string, null: false

      add :address, :jsonb
      add :sensor_data, :jsonb, default: "[]"
      add :recommandations, :jsonb, default: "[]"
      add :health_warnings, :jsonb, default: "[]"
      add :activity_type, :jsonb

      add :user_id, references(:users), null: false
      add :medic_profile_id, references(:medic_profiles)

      timestamps(type: :utc_datetime)
    end
  end
end
