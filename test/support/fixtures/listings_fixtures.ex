defmodule SwappersOnline.ListingsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SwappersOnline.Listings` context.
  """

  @doc """
  Generate a listing.
  """
  def listing_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        location: "some location",
        offering: "some offering",
        state: :live,
        wanted: "some wanted"
      })

    {:ok, listing} = SwappersOnline.Listings.create_listing(scope, attrs)
    listing
  end
end
