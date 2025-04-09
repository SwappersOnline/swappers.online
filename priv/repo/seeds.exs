# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     LocationSearch.Repo.insert!(%LocationSearch.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# NOTE ADJUST FOR CORES
cores = 32
batch_size = 1000

states = [
  {"Alabama", "geo_data/US/raw_al.json"},
  {"Alaska", "geo_data/US/raw_ak.json"},
  {"Arizona", "geo_data/US/raw_az.json"},
  {"Arkansas", "geo_data/US/raw_ar.json"},
  {"California", "geo_data/US/raw_ca.json"},
  {"Colorado", "geo_data/US/raw_co.json"},
  {"Connecticut", "geo_data/US/raw_ct.json"},
  {"Delaware", "geo_data/US/raw_de.json"},
  {"Florida", "geo_data/US/raw_fl.json"},
  {"Georgia", "geo_data/US/raw_ga.json"},
  {"Hawaii", "geo_data/US/raw_hi.json"},
  {"Idaho", "geo_data/US/raw_id.json"},
  {"Illinois", "geo_data/US/raw_il.json"},
  {"Indiana", "geo_data/US/raw_in.json"},
  {"Iowa", "geo_data/US/raw_ia.json"},
  {"Kansas", "geo_data/US/raw_ks.json"},
  {"Kentucky", "geo_data/US/raw_ky.json"},
  {"Louisiana", "geo_data/US/raw_la.json"},
  {"Maine", "geo_data/US/raw_me.json"},
  {"Maryland", "geo_data/US/raw_md.json"},
  {"Massachusetts", "geo_data/US/raw_ma.json"},
  {"Michigan", "geo_data/US/raw_mi.json"},
  {"Minnesota", "geo_data/US/raw_mn.json"},
  {"Mississippi", "geo_data/US/raw_mi.json"},
  {"Missouri", "geo_data/US/raw_mo.json"},
  {"Montana", "geo_data/US/raw_mn.json"},
  {"Nebraska", "geo_data/US/raw_ne.json"},
  {"Nevada", "geo_data/US/raw_nv.json"},
  {"New Hampshire", "geo_data/US/raw_nh.json"},
  {"New Jersey", "geo_data/US/raw_nj.json"},
  {"New Mexico", "geo_data/US/raw_nm.json"},
  {"New York", "geo_data/US/raw_ny.json"},
  {"North Carolina", "geo_data/US/raw_nc.json"},
  {"North Dakota", "geo_data/US/raw_nd.json"},
  {"Ohio", "geo_data/US/raw_oh.json"},
  {"Oklahoma", "geo_data/US/raw_ok.json"},
  {"Oregon", "geo_data/US/raw_or.json"},
  {"Pennsylvania", "geo_data/US/raw_pa.json"},
  {"Rhode Island", "geo_data/US/raw_ri.json"},
  {"South Carolina", "geo_data/US/raw_sc.json"},
  {"South Dakota", "geo_data/US/raw_sd.json"},
  {"Tennessee", "geo_data/US/raw_tn.json"},
  {"Texas", "geo_data/US/raw_tx.json"},
  {"Utah", "geo_data/US/raw_ut.json"},
  {"Vermont", "geo_data/US/raw_vt.json"},
  {"Virginia", "geo_data/US/raw_va.json"},
  {"Washington", "geo_data/US/raw_wa.json"},
  {"West Virginia", "geo_data/US/raw_wv.json"},
  {"Wisconsin", "geo_data/US/raw_wi.json"},
  {"Wyoming", "geo_data/US/raw_wy.json"}
]

Enum.map(states, fn {state, path} ->
  json = File.read!(path) |> JSON.decode!()

  # used to filter suburbs.
  # Options: ["city", "town", "village", "hamlet", "suburb"]
  places = ["city", "town", "village", "hamlet", "suburb"]

  locations =
    Enum.filter(json["elements"], fn %{"tags" => %{"place" => place}} -> place in places end)

  now = DateTime.utc_now() |> DateTime.truncate(:second)

  Enum.map(locations, fn
    %{"tags" => %{"official_name" => name}, "center" => %{"lat" => lat, "lon" => lon}} ->
      %{
        inserted_at: now,
        updated_at: now,
        name: name,
        geom: %Geo.Point{coordinates: {lon, lat}, srid: 4326},
        state: state,
        country: "US"
      }

    %{"tags" => %{"official_name" => name}, "lat" => lat, "lon" => lon} ->
      %{
        inserted_at: now,
        updated_at: now,
        name: name,
        geom: %Geo.Point{coordinates: {lon, lat}, srid: 4326},
        state: state,
        country: "US"
      }

    %{"tags" => %{"name" => name}, "center" => %{"lat" => lat, "lon" => lon}} ->
      %{
        inserted_at: now,
        updated_at: now,
        name: name,
        geom: %Geo.Point{coordinates: {lon, lat}, srid: 4326},
        state: state,
        country: "US"
      }

    %{"tags" => %{"name" => name}, "lat" => lat, "lon" => lon} ->
      %{
        inserted_at: now,
        updated_at: now,
        name: name,
        geom: %Geo.Point{coordinates: {lon, lat}, srid: 4326},
        state: state,
        country: "US"
      }

    location ->
      raise dbg(location)
  end)
end)
|> List.flatten()
|> Enum.uniq_by(fn %{state: state, name: name} -> [state, name] end)
|> Stream.chunk_every(batch_size)
|> Flow.from_enumerable(stages: cores)
|> Flow.map(fn batch ->
  SwappersOnline.Repo.insert_all(SwappersOnline.Locations.Location, batch, returning: false)
end)
|> Flow.run()
