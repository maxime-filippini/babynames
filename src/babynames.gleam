import app/router
import babynames/cli
import gleam/io

import babynames/auth/google
import babynames/web.{Context}
import envoy
import gleam/erlang/process
import mist
import pog
import wisp

import wisp/wisp_mist

/// Initialize the database via the URL stored in the environment
fn db() -> pog.Connection {
  let assert Ok(db_url) = envoy.get("DATABASE_URL")
  let assert Ok(cfg) = pog.url_config(db_url)

  cfg
  |> pog.pool_size(15)
  |> pog.connect
}

pub fn main() {
  let args = cli.parse_args()

  io.debug("Beginning")

  // The Google credentials are required to set up OAuth
  let assert Ok(google_creds) = google.load_credentials()

  io.debug("Google credentials loaded from ENV")
  io.debug(google_creds)

  // Secret key is used to sign cookies
  let assert Ok(secret_key_base) = envoy.get("WISP_SECRET_KEY_BASE")

  wisp.configure_logger()

  io.debug("Logger configured")

  let ctx =
    Context(static_directory: static_directory(), google_creds:, db: db())

  let handler = router.route_request(_, ctx)

  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(args.port)
    |> mist.bind("0.0.0.0")
    |> mist.start_http

  process.sleep_forever()
}

/// Directory used to store static assets
pub fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("babynames")
  priv_directory <> "/static"
}
