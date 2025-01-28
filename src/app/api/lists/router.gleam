import app/api/lists/views
import babynames/auth/user.{type Unverified, type User}
import babynames/utils
import babynames/web
import gleam/http.{Get}
import gleam/option.{type Option}

import wisp.{type Request, type Response}

// Protected route
pub fn route_request(
  req: Request,
  ctx: web.Context,
  maybe_user: Option(User(Unverified)),
  segments: List(String),
) -> Response {
  use req, user <- web.authenticate(req, ctx, maybe_user)

  // /api/lists/...
  case req.method, segments {
    Get, [] -> views.get_all_lists_for_user(ctx.db, user) |> utils.to_response
    Get, [id] -> views.get_list_for_user(ctx.db, id) |> utils.to_response
    Get, [id, "items"] -> views.get_list_items(ctx.db, id) |> utils.to_response
    _, _ -> wisp.not_found()
  }
}
