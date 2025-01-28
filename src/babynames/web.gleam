import babynames/auth/cookie
import babynames/auth/google
import babynames/auth/user.{type Unverified, type User, type Verified}
import gleam/list
import gleam/option.{type Option, None, Some}
import pog
import sql.{type UserRole}
import wisp

const login_endpoint = "/auth/login"

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
  handle_request: fn(wisp.Request, Option(User(Unverified))) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)

  let maybe_user = user.from_cookie(req)
  // use req, user <- authenticate(req, ctx, maybe_user)

  handle_request(req, maybe_user)
}

pub fn authenticate(
  req: wisp.Request,
  ctx: Context,
  maybe_user: option.Option(User(Unverified)),
  handle_request: fn(wisp.Request, User(Verified)) -> wisp.Response,
) {
  case maybe_user {
    Some(v) -> {
      case user.verify(v, ctx.db) {
        Ok(u) -> handle_request(req, u)
        Error(_) -> {
          wisp.redirect(login_endpoint)
          |> cookie.with_invalidated_user_cookie(req, _)
        }
      }
    }
    None -> {
      wisp.redirect(login_endpoint)
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
