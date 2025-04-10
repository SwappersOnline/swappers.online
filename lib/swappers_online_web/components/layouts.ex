defmodule SwappersOnlineWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is rendered as component
  in regular views and live views.
  """
  use SwappersOnlineWeb, :html

  embed_templates "layouts/*"

  def app(assigns) do
    ~H"""
    <header class="navbar py-8 px-4 sm:px-6 lg:px-8 mx-auto max-w-7xl">
      <div class="flex-1 ">
        <a href="/" class="flex-1 flex items-center gap-2">
          <svg
            class="size-10"
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

          <span class="text-xl font-semibold">Swappers</span>
        </a>
      </div>
      <div class="flex items-center gap-x-4">
        <details :if={@current_scope} class="dropdown dropdown-end">
          <summary class="btn btn-circle m-1">
            <.icon name="hero-user-circle" class="size-6" />
          </summary>
          <ul class="menu dropdown-content bg-base-100 rounded-box z-1 w-52 p-2 shadow-sm">
            <li>
              <.link href={~p"/users/settings"}>{@current_scope.user.email}</.link>
            </li>
            <li>
              <.link href={~p"/listings"}>My Listings</.link>
            </li>
            <li></li>
            <li>
              <.link href={~p"/users/log-out"} method="delete">Log out</.link>
            </li>
          </ul>
        </details>

        <ul
          :if={!@current_scope}
          class="menu menu-horizontal w-full relative z-10 flex items-center gap-4 justify-end"
        >
          <li>
            <.link href={~p"/users/register"}>Register</.link>
          </li>
          <li>
            <.link href={~p"/users/log-in"}>
              Log in
            </.link>
          </li>
        </ul>

        <.theme_toggle />
      </div>
    </header>

    {render_slot(@inner_block)}

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Hang in there while we get back on track")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="flex items-center">
      <span
        class="cursor-pointer [[data-theme=dark]_&]:hidden"
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "dark"})}
      >
        <.icon name="hero-sun-micro" class="size-6 opacity-75 hover:opacity-100" />
      </span>
      <span
        class="cursor-pointer [[data-theme=light]_&]:hidden"
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "light"})}
      >
        <.icon name="hero-moon-micro" class="size-6 opacity-75 hover:opacity-100" />
      </span>
    </div>
    """
  end
end
