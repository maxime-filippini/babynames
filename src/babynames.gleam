import envoy
import gleam/erlang/process
import mist
import pog
import server/auth/google
import server/router
import server/web.{Context}
import wisp

import wisp/wisp_mist

fn db() -> pog.Connection {
  let assert Ok(db_url) = envoy.get("DATABASE_URL")
  let assert Ok(cfg) = pog.url_config(db_url)

  cfg
  |> pog.pool_size(15)
  |> pog.connect
}

pub fn main() {
  let assert Ok(google_creds) = google.load_credentials()
  let assert Ok(secret_key_base) = envoy.get("WISP_SECRET_KEY_BASE")

  wisp.configure_logger()
  let ctx =
    Context(static_directory: static_directory(), google_creds:, db: db())
  let handler = router.handle_request(_, ctx)

  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

pub fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("babynames")
  priv_directory <> "/static"
}
