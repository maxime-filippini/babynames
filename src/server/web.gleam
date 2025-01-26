import gleam/io
import gleam/list
import gleam/option.{None, Some}
import pog
import server/auth/cookie
import server/auth/google
import server/auth/user
import sql.{type UserRole}
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

  handle_request(req, usr)
}

pub fn authenticate(
  req: wisp.Request,
  ctx: Context,
  maybe_user: option.Option(user.User(user.Unverified)),
  handle_request: fn(wisp.Request, user.User(user.Verified)) -> wisp.Response,
) {
  case maybe_user {
    Some(v) -> {
      case user.verify(v, ctx.db) {
        Ok(u) -> handle_request(req, u)
        Error(_) -> {
          wisp.response(401) |> cookie.with_invalidated_user_cookie(req, _)
        }
      }
    }
    None -> {
      wisp.response(401)
    }
  }
}

pub fn authorize(
  req: wisp.Request,
  user: user.User(user.Verified),
  valid_roles: List(UserRole),
  handle_request: fn(wisp.Request, user.User(user.Verified)) -> wisp.Response,
) {
  case list.contains(valid_roles, user.role) {
    True -> handle_request(req, user)
    False -> wisp.response(403)
  }
}
