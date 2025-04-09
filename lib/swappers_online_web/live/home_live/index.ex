defmodule SwappersOnlineWeb.HomeLive.Index do
  use SwappersOnlineWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <main class="px-4 sm:px-6 lg:px-8 mx-auto max-w-7xl">
        <div class="relative isolate px-6 lg:px-8">
          <div class="mx-auto max-w-7xl py-18">
            <div class="text-center relative ">
              <div class="">
                <svg
                  class="inline mr-2 size-30 md:size-50"
                  width="135.55075mm"
                  height="141.55185mm"
                  viewBox="0 0 135.55075 141.55185"
                >
                  <g transform="translate(-35.589337,-25.293968)">
                    <g transform="matrix(0.94319498,0,0,0.94319498,2.6213083,-48.727409)">
                      <path
                        class="fill-primary"
                        style="opacity:0.98;vector-effect:none;stroke:none;stroke-width:4.49e-06;paint-order:fill markers stroke;stop-color:#000000;stop-opacity:1"
                        d="m 106.8106,83.661317 c -37.233205,1.49e-4 -67.41656,30.183743 -67.416409,67.416953 -1.55e-4,37.23321 30.183201,67.41681 67.416409,67.41696 3.36877,-0.0109 6.732,-0.27423 10.0614,-0.78787 2.31982,-0.37892 4.61824,-0.87891 6.88584,-1.49792 v 0 l 4.5776,7.92847 6.9105,-11.97023 v 0 l 20.1343,-34.87301 h -17.61731 -36.47229 l 8.23857,14.27026 c -0.90295,0.11966 -1.80967,0.20902 -2.71861,0.26792 -1.73292,-0.0597 -3.46027,-0.22985 -5.17151,-0.50953 -20.27497,-2.59367 -35.492352,-19.80505 -35.582523,-40.24505 1.3e-4,-22.50778 18.246256,-40.7539 40.754033,-40.75403 22.50799,-1.7e-4 40.75445,18.24604 40.75458,40.75403 -0.0676,6.83402 -1.85275,13.54131 -5.19123,19.50478 h 24.6319 l -19.76009,34.22541 c 16.92454,-12.68583 26.91442,-32.57916 26.98179,-53.73019 1.5e-4,-37.23342 -30.18353,-67.417103 -67.41695,-67.416953 z m 15.49534,99.114963 c 0.51139,-0.006 1.02818,0.009 1.54449,0.0449 2.23136,0.15946 4.35076,0.70648 5.93526,1.5319 1.75847,0.91003 2.71524,2.08341 2.64027,3.23801 -0.16062,2.29059 -4.26083,3.86886 -9.15793,3.5251 -1.86687,-0.15839 -3.64817,-0.58775 -5.08932,-1.22672 -2.22251,-0.91865 -3.51468,-2.23173 -3.48676,-3.54318 0.14128,-2.01272 3.35175,-3.51804 7.61399,-3.57003 z m 13.20189,10.3326 c 0.69079,0.0625 1.2454,0.31268 1.63215,0.73636 1.62622,1.7819 -0.0261,6.15659 -3.69057,9.77102 -3.66426,3.61406 -7.95268,5.0993 -9.5787,3.31745 -1.62612,-1.78179 0.0259,-6.15611 3.69001,-9.77047 2.68346,-2.64683 5.81998,-4.24698 7.94711,-4.05436 z"
                      />
                    </g>
                  </g>
                </svg>
              </div>
              <div class="relative z-20">
                <h1 class="text-balance font-semibold tracking-tight text-3xl md:text-7xl flex items-center justify-center">
                  Swappers.Online
                </h1>
                <p class="mt-8 text-pretty text-lg font-medium sm:text-xl/8">
                  An online market for bartering swapping goods with your local community
                </p>
                <div class="mt-8">
                  <.link
                    class="btn btn-primary btn-md lg:btn-lg xl:btn-xl"
                    navigate={~p"/listings/new"}
                  >
                    <.icon name="hero-plus-circle" class="size-8" /> Submit Listing
                  </.link>
                </div>
              </div>
            </div>
            <div class="divider my-20">Live Listings</div>

            <div :if={@filter} class="mx-auto w-fit">
              Filtering to {@filter.name}
            </div>
            <div :if={!@filter} class="mx-auto w-fit mb-10">
              <p class="text-center my-6">Filter by location</p>
              <.form
                for={@form}
                id="city-search"
                phx-change="city-search-validate"
                phx-submit="city-search-save"
                class="flex gap-x-4 w-fit"
              >
                <label>
                  <span class="fieldset-label mb-1">City</span>
                  <input
                    type="text"
                    name="form[city]"
                    id="form_city"
                    value=""
                    class="input"
                    phx-debounce="1000"
                  />
                </label>

                <label>
                  <span class="fieldset-label mb-1">State</span>
                  <input
                    type="text"
                    name="form[state]"
                    id="form_state"
                    value=""
                    class="input"
                    phx-debounce="1000"
                  />
                </label>
              </.form>

              <div :if={@filter_ops != []} class="dropdown dropdown-open">
                <ul class="dropdown-content menu bg-base-100 rounded-box z-20 w-52 p-2 shadow-sm">
                  <li :for={loc <- @filter_ops} phx-click="select-loc">
                    <a href="#" class="cursor-pointer" phx-click="set-loc" phx-value-id={loc.id}>
                      {loc.name}
                    </a>
                  </li>
                </ul>
              </div>
            </div>
            <div id="listings" phx-update="stream" class="mb-16">
              <div
                :for={{id, listing} <- @streams.listings}
                id={id}
                class="rounded-lg bg-base-100 shadow-xl m-4 p-8"
              >
                <div class="flex w-full flex-col">
                  <div class="grid place-items-center mb-10">
                    <h3 class="text-primary font-semibold text-xl">{listing.location.name}, {listing.location.state}</h3>

                    <p :if={listing.no_wanted || listing.no_offer} class="mt-1 text-sm text-center">
                      <div class={["badge", listing.no_wanted && "badge-info", listing.no_offer && "badge-warning"]}>WANTED/OFFERING FOR FREE</div>
                    </p>
                    <div class="badge badge-soft badge-secondary my-4">
                      {Timex.format!(listing.inserted_at, "{WDshort} {Mshort} {D} {YYYY}")}
                    </div>
                  </div>
                  <div class="grid place-items-center">
                    <div class="flex w-full flex-col lg:flex-row ">
                      <div :if={!(listing.no_wanted)}class="flex-1 mx-4 grid h-32 grow place-items-center text-center">
                        <div>
                          <div class="badge badge-warning">Wanted</div>
                        </div>
                        {listing.wanted}
                      </div>
                      <div :if={!(listing.no_wanted || listing.no_offer) } class="divider lg:divider-horizontal">For</div>
                      <div :if={!(listing.no_offer)}class="flex-1 mx-4 grid h-32 grow place-items-center text-center">
                        <div>
                          <div class="badge badge-info">Offering</div>
                        </div>
                        {listing.offering}
                      </div>
                    </div>
                  </div>
                  <div class="mt-8 mx-auto" :if={!(listing.no_wanted || listing.no_offer)} >
                    <button class="btn btn-primary btn-md lg:btn-lg xl:btn-xl">
                      Offer Trade <.icon name="hero-scale" class="size-6" />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </Layouts.app>
    """
  end

  def mount(_, _session, socket) do
    listings = SwappersOnline.Listings.list_listings()

    {:ok,
     socket
     |> stream(:listings, listings)
     |> assign(form: to_form(%{"city" => "", "state" => ""}, as: "form"))
     |> assign(filter: nil)
     |> assign(filter_ops: [])}
  end

  def handle_event(
        "set-loc",
        %{"id" => select_id},
        %{assigns: %{filter_ops: filter_ops}} = socket
      ) do
    filter = Enum.find(filter_ops, fn %{id: id} -> id == select_id |> String.to_integer() end)

    {:noreply, socket |> assign(filter: filter, filter_ops: [])}
  end
end
