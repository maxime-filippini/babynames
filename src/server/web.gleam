import pog
import server/auth/google
import wisp

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
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)

  handle_request(req)
}
