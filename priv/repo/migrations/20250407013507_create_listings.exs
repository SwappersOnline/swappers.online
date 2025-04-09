defmodule SwappersOnline.Repo.Migrations.CreateListings do
  use Ecto.Migration

  def change do
    create table(:listings) do
      add :wanted, :string
      add :offering, :string
      add :state, :string
      add :no_offer, :boolean, null: false, default: false
      add :no_wanted, :boolean, null: false, default: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)
      add :location_id, references(:locations, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
