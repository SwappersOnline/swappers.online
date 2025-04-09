defmodule SwappersOnlineWeb.ListingLive.Show do
  use SwappersOnlineWeb, :live_view

  alias SwappersOnline.Listings

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing {@listing.id}
        <:subtitle>This is a listing record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/listings"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/listings/#{@listing}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit listing
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Wanted">{@listing.wanted}</:item>
        <:item title="Offering">{@listing.offering}</:item>
        <:item title="Location">{@listing.location}</:item>
        <:item title="State">{@listing.state}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    Listings.subscribe_listings(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Show Listing")
     |> assign(:listing, Listings.get_listing!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %SwappersOnline.Listings.Listing{id: id} = listing},
        %{assigns: %{listing: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :listing, listing)}
  end

  def handle_info(
        {:deleted, %SwappersOnline.Listings.Listing{id: id}},
        %{assigns: %{listing: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current listing was deleted.")
     |> push_navigate(to: ~p"/listings")}
  end
end
