defmodule SwappersOnline.Listings.Listing do
  use Ecto.Schema
  import Ecto.Changeset

  schema "listings" do
    field :wanted, :string
    field :offering, :string
    field :state, Ecto.Enum, values: [:live, :traded, :ended, :flagged]
    field :user_id, :binary_id
    field :no_offer, :boolean, default: false
    field :no_wanted, :boolean, default: false
    belongs_to :location, SwappersOnline.Locations.Location, type: :binary_id
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(listing, attrs, user_scope) do
    listing
    |> cast(attrs, [:wanted, :offering, :location_id, :no_offer, :no_wanted])
    |> validate_required([:location_id])
    |> validate_length(:wanted, max: 256)
    |> validate_length(:offering, max: 256)
    |> put_change(:state, :live)
    |> put_change(:user_id, user_scope.user.id)
  end
end
