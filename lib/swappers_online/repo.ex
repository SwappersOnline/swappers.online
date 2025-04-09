defmodule SwappersOnline.Repo do
  use Ecto.Repo,
    otp_app: :swappers_online,
    adapter: Ecto.Adapters.Postgres,
    extensions: [Geo.PostGIS.Extension]
end
