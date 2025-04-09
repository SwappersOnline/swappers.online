defmodule SwappersOnline.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    execute "CREATE EXTENSION IF NOT EXISTS postgis;"

    create table(:locations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :state, :string
      add :country, :string
      add :geom, :geometry, srid: 4326

      timestamps(type: :utc_datetime)
    end

    execute """
      ALTER TABLE locations
      ADD COLUMN fuzzy_search text
      GENERATED ALWAYS AS (name || ' ' || state) STORED;
    """

    execute "CREATE INDEX locations_fuzzy_search_idx ON locations USING GIST (fuzzy_search gist_trgm_ops);"

    create unique_index(:locations, [:name, :state])
    create index(:locations, [:geom], using: :gist)
  end
end
