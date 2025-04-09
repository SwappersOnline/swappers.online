defmodule SwappersOnlineWeb.ListingLiveTest do
  use SwappersOnlineWeb.ConnCase

  import Phoenix.LiveViewTest
  import SwappersOnline.ListingsFixtures

  @create_attrs %{state: :live, location: "some location", wanted: "some wanted", offering: "some offering"}
  @update_attrs %{state: :traded, location: "some updated location", wanted: "some updated wanted", offering: "some updated offering"}
  @invalid_attrs %{state: nil, location: nil, wanted: nil, offering: nil}

  setup :register_and_log_in_user

  defp create_listing(%{scope: scope}) do
    listing = listing_fixture(scope)

    %{listing: listing}
  end

  describe "Index" do
    setup [:create_listing]

    test "lists all listings", %{conn: conn, listing: listing} do
      {:ok, _index_live, html} = live(conn, ~p"/listings")

      assert html =~ "Listing Listings"
      assert html =~ listing.wanted
    end

    test "saves new listing", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/listings")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Listing")
               |> render_click()
               |> follow_redirect(conn, ~p"/listings/new")

      assert render(form_live) =~ "New Listing"

      assert form_live
             |> form("#listing-form", listing: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#listing-form", listing: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/listings")

      html = render(index_live)
      assert html =~ "Listing created successfully"
      assert html =~ "some wanted"
    end

    test "updates listing in listing", %{conn: conn, listing: listing} do
      {:ok, index_live, _html} = live(conn, ~p"/listings")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#listings-#{listing.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/listings/#{listing}/edit")

      assert render(form_live) =~ "Edit Listing"

      assert form_live
             |> form("#listing-form", listing: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#listing-form", listing: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/listings")

      html = render(index_live)
      assert html =~ "Listing updated successfully"
      assert html =~ "some updated wanted"
    end

    test "deletes listing in listing", %{conn: conn, listing: listing} do
      {:ok, index_live, _html} = live(conn, ~p"/listings")

      assert index_live |> element("#listings-#{listing.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#listings-#{listing.id}")
    end
  end

  describe "Show" do
    setup [:create_listing]

    test "displays listing", %{conn: conn, listing: listing} do
      {:ok, _show_live, html} = live(conn, ~p"/listings/#{listing}")

      assert html =~ "Show Listing"
      assert html =~ listing.wanted
    end

    test "updates listing and returns to show", %{conn: conn, listing: listing} do
      {:ok, show_live, _html} = live(conn, ~p"/listings/#{listing}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/listings/#{listing}/edit?return_to=show")

      assert render(form_live) =~ "Edit Listing"

      assert form_live
             |> form("#listing-form", listing: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#listing-form", listing: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/listings/#{listing}")

      html = render(show_live)
      assert html =~ "Listing updated successfully"
      assert html =~ "some updated wanted"
    end
  end
end
