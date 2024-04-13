defmodule HealthguardApi.Repo.Migrations.CreateMedicProfiles do
  use Ecto.Migration

  def change do
    create table(:medic_profiles) do
      add :badge_number, :string, null: false

      add :user_id, references(:users), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
