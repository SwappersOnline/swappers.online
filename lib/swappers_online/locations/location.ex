defmodule SwappersOnline.Locations.Location do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "locations" do
    field :name, :string
    field :state, :string
    field :country, :string
    field :geom, Geo.PostGIS.Geometry, type: :point
    field :lat, :float, virtual: true
    field :lon, :float, virtual: true
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :state, :country, :lat, :lon])
    |> validate_required([:name, :state, :country, :lat, :lon])
    |> validate_required([:lat, :lon])
    |> validate_number(:lat, greater_than_or_equal_to: -90, less_than_or_equal_to: 90)
    |> validate_number(:lon, greater_than_or_equal_to: -180, less_than_or_equal_to: 180)
    |> unique_constraint([:name, :state])
    |> put_geom_from_coordinates()
  end

  defp put_geom_from_coordinates(changeset) do
    case changeset do
      %{valid?: true, changes: %{lat: lat, lon: lon}} ->
        point = %Geo.Point{coordinates: {lon, lat}, srid: 4326}
        put_change(changeset, :geom, point)

      _ ->
        changeset
    end
  end
end
