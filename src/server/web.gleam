import gleam/io
import pog
import server/auth/google
import wisp

pub type Context {
  Context(
    static_directory: String,
    google_creds: google.AuthCredentials,
    db: pog.Connection,
  )
}

pub fn middleware(
  req: wisp.Request,
  ctx: Context,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)

  // Check for cookie
  case wisp.get_cookie(req, "token", wisp.Signed) {
    Ok(v) -> {
      io.debug(v)
    }
    _ -> {
      io.debug("no cookie")
    }
  }

  handle_request(req)
}
