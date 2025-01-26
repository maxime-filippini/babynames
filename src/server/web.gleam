import gleam/option.{None, Some}
import pog
import server/auth/google
import server/auth/user
import wisp.{log_info}

/// Context object passed by handler with each request.
/// This object does not change over the lifetime of the process.
/// 
pub type Context {
  Context(
    static_directory: String,
    google_creds: google.AuthCredentials,
    db: pog.Connection,
  )
}

/// Standard middleware stack
/// 
pub fn middleware(
  req: wisp.Request,
  ctx: Context,
  handle_request: fn(wisp.Request, option.Option(user.User(user.Unverified))) ->
    wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)

  let usr = user.from_cookie(req)

  case usr {
    Some(v) -> log_info("Unverified user: " <> v.id)
    None -> log_info("No user found in cookie.")
  }

  handle_request(req, usr)
}
