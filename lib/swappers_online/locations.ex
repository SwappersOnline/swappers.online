defmodule SwappersOnline.Locations do
  @moduledoc """
  The Locations context.
  """

  import Ecto.Query, warn: false
  alias SwappersOnline.Repo

  alias SwappersOnline.Locations.Location

  @doc """
  Returns the list of locations.

  ## Examples

      iex> list_locations()
      [%Location{}, ...]

  """
  def list_locations do
    Repo.all(Location)
  end

  @doc """
  Gets a single location.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location!(123)
      %Location{}

      iex> get_location!(456)
      ** (Ecto.NoResultsError)

  """
  def get_location!(id), do: Repo.get!(Location, id)

  @doc """
  Creates a location.

  ## Examples

      iex> create_location(%{field: value})
      {:ok, %Location{}}

      iex> create_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_location(attrs \\ %{}) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a location.

  ## Examples

      iex> update_location(location, %{field: new_value})
      {:ok, %Location{}}

      iex> update_location(location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a location.

  ## Examples

      iex> delete_location(location)
      {:ok, %Location{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(%Location{} = location) do
    Repo.delete(location)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.

  ## Examples

      iex> change_location(location)
      %Ecto.Changeset{data: %Location{}}

  """
  def change_location(%Location{} = location, attrs \\ %{}) do
    Location.changeset(location, attrs)
  end

  # def search_locations(query_text) do
  #   Location
  #   |> where([l], fragment("search_vector @@ websearch_to_tsquery('english', ?)", ^query_text))
  #   |> order_by(
  #     [l],
  #     fragment("ts_rank_cd(search_vector, websearch_to_tsquery('english', ?)) DESC", ^query_text)
  #   )
  #   |> LocationSearch.Repo.all()
  # end
  def search_locations(query_text) do
    Location
    |> where(
      [l],
      fragment(
        "fuzzy_search % ? OR similarity(fuzzy_search, ?) > 0.3",
        ^query_text,
        ^query_text
      )
    )
    |> order_by(
      [l],
      fragment("similarity(fuzzy_search, ?) DESC", ^query_text)
    )
    |> limit(5)
    |> Repo.all()
  end

  def get_nearby_locations(%{geom: geom, id: id}) do
    from(l in Location,
      where: l.id != ^id,
      order_by: fragment("ST_Distance(geom::geography, ?::geography)", ^geom),
      limit: 20,
      select: %{
        id: l.id,
        name: l.name,
        state: l.state,
        geom: l.geom,
        distance:
          fragment(
            "ST_Distance(geom::geography, ?::geography) / 1609.34 as distance",
            ^geom
          )
      }
    )
    |> SwappersOnline.Repo.all()
  end
end
