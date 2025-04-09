defmodule SwappersOnline.ListingsTest do
  use SwappersOnline.DataCase

  alias SwappersOnline.Listings

  describe "listings" do
    alias SwappersOnline.Listings.Listing

    import SwappersOnline.AccountsFixtures, only: [user_scope_fixture: 0]
    import SwappersOnline.ListingsFixtures

    @invalid_attrs %{state: nil, location: nil, wanted: nil, offering: nil}

    test "list_listings/1 returns all scoped listings" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      listing = listing_fixture(scope)
      other_listing = listing_fixture(other_scope)
      assert Listings.list_listings(scope) == [listing]
      assert Listings.list_listings(other_scope) == [other_listing]
    end

    test "get_listing!/2 returns the listing with given id" do
      scope = user_scope_fixture()
      listing = listing_fixture(scope)
      other_scope = user_scope_fixture()
      assert Listings.get_listing!(scope, listing.id) == listing
      assert_raise Ecto.NoResultsError, fn -> Listings.get_listing!(other_scope, listing.id) end
    end

    test "create_listing/2 with valid data creates a listing" do
      valid_attrs = %{state: :live, location: "some location", wanted: "some wanted", offering: "some offering"}
      scope = user_scope_fixture()

      assert {:ok, %Listing{} = listing} = Listings.create_listing(scope, valid_attrs)
      assert listing.state == :live
      assert listing.location == "some location"
      assert listing.wanted == "some wanted"
      assert listing.offering == "some offering"
      assert listing.user_id == scope.user.id
    end

    test "create_listing/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Listings.create_listing(scope, @invalid_attrs)
    end

    test "update_listing/3 with valid data updates the listing" do
      scope = user_scope_fixture()
      listing = listing_fixture(scope)
      update_attrs = %{state: :traded, location: "some updated location", wanted: "some updated wanted", offering: "some updated offering"}

      assert {:ok, %Listing{} = listing} = Listings.update_listing(scope, listing, update_attrs)
      assert listing.state == :traded
      assert listing.location == "some updated location"
      assert listing.wanted == "some updated wanted"
      assert listing.offering == "some updated offering"
    end

    test "update_listing/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      listing = listing_fixture(scope)

      assert_raise MatchError, fn ->
        Listings.update_listing(other_scope, listing, %{})
      end
    end

    test "update_listing/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      listing = listing_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Listings.update_listing(scope, listing, @invalid_attrs)
      assert listing == Listings.get_listing!(scope, listing.id)
    end

    test "delete_listing/2 deletes the listing" do
      scope = user_scope_fixture()
      listing = listing_fixture(scope)
      assert {:ok, %Listing{}} = Listings.delete_listing(scope, listing)
      assert_raise Ecto.NoResultsError, fn -> Listings.get_listing!(scope, listing.id) end
    end

    test "delete_listing/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      listing = listing_fixture(scope)
      assert_raise MatchError, fn -> Listings.delete_listing(other_scope, listing) end
    end

    test "change_listing/2 returns a listing changeset" do
      scope = user_scope_fixture()
      listing = listing_fixture(scope)
      assert %Ecto.Changeset{} = Listings.change_listing(scope, listing)
    end
  end
end
