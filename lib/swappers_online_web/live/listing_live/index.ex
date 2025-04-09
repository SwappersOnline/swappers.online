defmodule SwappersOnlineWeb.ListingLive.Index do
  use SwappersOnlineWeb, :live_view

  alias SwappersOnline.Listings

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <main class="px-4 sm:px-6 lg:px-8 mx-auto max-w-7xl">
        <.header>
          Listing Listings
          <:actions>
            <.button variant="primary" navigate={~p"/listings/new"}>
              <.icon name="hero-plus" /> New Listing
            </.button>
          </:actions>
        </.header>

        <.table
          id="listings"
          rows={@streams.listings}
          row_click={fn {_id, listing} -> JS.navigate(~p"/listings/#{listing}") end}
        >
          <:col :let={{_id, listing}} label="Wanted">{listing.wanted}</:col>
          <:col :let={{_id, listing}} label="Offering">{listing.offering}</:col>
          <:col :let={{_id, listing}} label="State">{listing.state}</:col>
          <:action :let={{_id, listing}}>
            <div class="sr-only">
              <.link navigate={~p"/listings/#{listing}"}>Show</.link>
            </div>
            <.link navigate={~p"/listings/#{listing}/edit"}>Edit</.link>
          </:action>
          <:action :let={{id, listing}}>
            <.link
              phx-click={JS.push("delete", value: %{id: listing.id}) |> hide("##{id}")}
              data-confirm="Are you sure?"
            >
              Delete
            </.link>
          </:action>
        </.table>
      </main>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    Listings.subscribe_listings(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Listing Listings")
     |> stream(:listings, Listings.list_listings(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    listing = Listings.get_listing!(socket.assigns.current_scope, id)
    {:ok, _} = Listings.delete_listing(socket.assigns.current_scope, listing)

    {:noreply, stream_delete(socket, :listings, listing)}
  end

  @impl true
  def handle_info({type, %SwappersOnline.Listings.Listing{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :listings, Listings.list_listings(socket.assigns.current_scope), reset: true)}
  end
end
