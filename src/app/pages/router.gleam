import app/pages/my_lists/views as my_lists_views

import babynames/auth/user.{type Unverified, type User}
import babynames/utils
import babynames/web
import gleam/option.{type Option}
import wisp.{type Request, type Response}

pub fn route_request(
  req: Request,
  ctx: web.Context,
  maybe_user: Option(User(Unverified)),
  segments: List(String),
) -> Response {
  use _req, user <- web.authenticate(req, ctx, maybe_user)
  case segments {
    [] -> my_lists_views.page(user, ctx.db) |> utils.to_response
    ["my-lists"] -> my_lists_views.page(user, ctx.db) |> utils.to_response

    _ -> wisp.not_found()
  }
}
