defmodule SwappersOnline.Listings do
  @moduledoc """
  The Listings context.
  """

  import Ecto.Query, warn: false
  alias SwappersOnline.Repo

  alias SwappersOnline.Listings.Listing
  alias SwappersOnline.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any listing changes.

  The broadcasted messages match the pattern:

    * {:created, %Listing{}}
    * {:updated, %Listing{}}
    * {:deleted, %Listing{}}

  """
  def subscribe_listings(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(SwappersOnline.PubSub, "user:#{key}:listings")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(SwappersOnline.PubSub, "user:#{key}:listings", message)
  end

  @doc """
  Returns the list of listings.

  ## Examples

      iex> list_listings(scope)
      [%Listing{}, ...]

  """
  def list_listings(%Scope{} = scope) do
    Repo.all(
      from listing in Listing, where: listing.user_id == ^scope.user.id, preload: [:location]
    )
  end

  def list_listings() do
    Repo.all(
      from listing in Listing,
        where: listing.state in [:live],
        order_by: [desc: listing.inserted_at],
        preload: [:location]
    )
  end

  @doc """
  Gets a single listing.

  Raises `Ecto.NoResultsError` if the Listing does not exist.

  ## Examples

      iex> get_listing!(123)
      %Listing{}

      iex> get_listing!(456)
      ** (Ecto.NoResultsError)

  """
  def get_listing!(%Scope{} = scope, id) do
    Repo.get_by!(Listing, id: id, user_id: scope.user.id)
    |> Repo.preload([:location])
  end

  @doc """
  Creates a listing.

  ## Examples

      iex> create_listing(%{field: value})
      {:ok, %Listing{}}

      iex> create_listing(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_listing(%Scope{} = scope, attrs \\ %{}) do
    with {:ok, listing = %Listing{}} <-
           %Listing{}
           |> Listing.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, listing})
      {:ok, listing}
    end
  end

  @doc """
  Updates a listing.

  ## Examples

      iex> update_listing(listing, %{field: new_value})
      {:ok, %Listing{}}

      iex> update_listing(listing, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_listing(%Scope{} = scope, %Listing{} = listing, attrs) do
    true = listing.user_id == scope.user.id

    with {:ok, listing = %Listing{}} <-
           listing
           |> Listing.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, listing})
      {:ok, listing}
    end
  end

  @doc """
  Deletes a listing.

  ## Examples

      iex> delete_listing(listing)
      {:ok, %Listing{}}

      iex> delete_listing(listing)
      {:error, %Ecto.Changeset{}}

  """
  def delete_listing(%Scope{} = scope, %Listing{} = listing) do
    true = listing.user_id == scope.user.id

    with {:ok, listing = %Listing{}} <-
           Repo.delete(listing) do
      broadcast(scope, {:deleted, listing})
      {:ok, listing}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking listing changes.

  ## Examples

      iex> change_listing(listing)
      %Ecto.Changeset{data: %Listing{}}

  """
  def change_listing(%Scope{} = scope, %Listing{} = listing, attrs \\ %{}) do
    true = listing.user_id == scope.user.id

    Listing.changeset(listing, attrs, scope)
  end
end
