defmodule SwappersOnlineWeb.ListingLive.Form do
  use SwappersOnlineWeb, :live_view

  alias SwappersOnline.Listings
  alias SwappersOnline.Listings.Listing

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <main class="px-4 sm:px-6 lg:px-8 mx-auto max-w-7xl">
        <.header>
          {@page_title}
          <:subtitle>
            <ul class="text-secondary">
              <li>
                You may submit a listing using up to 256 characters per field.
              </li>
              <li>
                Plese indicate if you are wanting / offering something for free by the checkbox on the bottom.
              </li>
              <li>
                You may create listings offering or wanting goods only. Listings that offer or seek services will be removed and your account will be banned.
              </li>
            </ul>
          </:subtitle>
        </.header>

        <.form for={@location_form} id="location-form" phx-change="location-validate" phx-submit="location-save">
          <.input
            field={@location_form[:location]}
            type="text"
            label="Search Location and Subburbs"
            placeholder="example: Portland, OR, TIP: you can even look for neighborhood names"
            autoComplete="off"
            phx-debounce="500"
          />

          <ul
            :if={@location_opts != [] || @location_selected}
            tabindex="0"
            class="my-4 bg-base-100 rounded-box z-1 p-2 shadow-xl"
          >
            <li :if={@location_selected} class="bg-info text-neutral flex items-center rounded-lg p-1">
              <span class="flex-1">
                {@location_selected.name}, {@location_selected.state}
              </span>
              <.icon name="hero-check-circle" class="size-4 mr-2" />
            </li>
            <li
              :for={location <- @location_opts}
              phx-value-id={location.id}
              phx-click="select_location"
              class="flex items-centered cursor-pointer hover:bg-base-300 rounded-lg p-1"
            >
              <span class="flex-1">{location.name}, {location.state}</span>
              <span
                :if={Map.get(location |> dbg(), :distance)}
                class="badge badge-soft badge-secondary mr-2"
              >
                {location.distance |> Float.round(2)} Miles away
              </span>
            </li>
          </ul>
        </.form>

        <.form for={@form} id="listing-form" phx-change="validate" phx-submit="save">

          <.input :if={@location_selected} field={@form[:location_id]} type="hidden" value={@location_selected.id} />

          <.input :if={@form[:no_wanted].value == false || @form[:no_wanted].value == "false"} field={@form[:wanted]} type="textarea" label="Wanted" />
          <.input
            field={@form[:no_wanted]}
            class="checkbox-warning"
            type="checkbox"
            label="I want nothing in return (I'm giving this away for free)"
          />

          <.input :if={@form[:no_offer].value == false || @form[:no_offer].value == "false"} field={@form[:offering]} type="textarea" label="Offering" />
          <.input
            field={@form[:no_offer] |> dbg() }
            class="checkbox-warning"
            type="checkbox"
            label="I have nothing to offer in return. (I want this for free)"
          />
          <footer>
            <.button phx-disable-with="Saving..." variant="primary">Save Listing</.button>
            <.button navigate={return_path(@current_scope, @return_to, @listing)}>Cancel</.button>
          </footer>
        </.form>
      </main>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:location_selected, nil)
     |> assign(:location_opts, [])
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:location_form, to_form(%{"location" => ""}))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    listing = Listings.get_listing!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Listing")
    |> assign(:listing, listing)
    |> assign(:form, to_form(Listings.change_listing(socket.assigns.current_scope, listing)))
  end

  defp apply_action(socket, :new, _params) do
    listing = %Listing{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Listing")
    |> assign(:listing, listing)
    |> assign(:form, to_form(Listings.change_listing(socket.assigns.current_scope, listing)))
  end

  @impl true
  def handle_event(
        "location-validate",
        %{
          "location" => location
        },
        socket
      ) do
    listing_opts = SwappersOnline.Locations.search_locations(location)

    {:noreply, socket |> assign(:location_opts, listing_opts)}
  end

  def handle_event("validate", %{"listing" => listing_params}, socket) do
    changeset =
      Listings.change_listing(
        socket.assigns.current_scope,
        socket.assigns.listing,
        listing_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"listing" => listing_params}, socket) do
    save_listing(socket, socket.assigns.live_action, listing_params)
  end

  def handle_event("select_location", %{"id" => id}, socket) do
    location = SwappersOnline.Locations.get_location!(id)
    closer_locations = SwappersOnline.Locations.get_nearby_locations(location)
    {:noreply, assign(socket, location_selected: location, location_opts: closer_locations)}
  end

  defp save_listing(socket, :edit, listing_params) do
    case Listings.update_listing(
           socket.assigns.current_scope,
           socket.assigns.listing,
           listing_params
         ) do
      {:ok, listing} ->
        {:noreply,
         socket
         |> put_flash(:info, "Listing updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, listing)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_listing(socket, :new, listing_params) do
    case Listings.create_listing(socket.assigns.current_scope, listing_params) do
      {:ok, listing} ->
        {:noreply,
         socket
         |> put_flash(:info, "Listing created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, listing)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _listing), do: ~p"/listings"
  defp return_path(_scope, "show", listing), do: ~p"/listings/#{listing}"
end
