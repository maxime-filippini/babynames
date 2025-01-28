import app/api/lists/router as lists_router
import babynames/auth/user.{type Unverified, type User}
import babynames/web
import gleam/option.{type Option}
import wisp.{type Request, type Response}

// The API is not globally behind authentication
// We may need to render some views via HTMX for non-authed users
pub fn route_request(
  req: Request,
  ctx: web.Context,
  maybe_user: Option(User(Unverified)),
  segments: List(String),
) -> Response {
  case segments {
    ["lists", ..rest] -> lists_router.route_request(req, ctx, maybe_user, rest)
    _ -> wisp.not_found()
  }
}
