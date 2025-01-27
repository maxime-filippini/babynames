import gleam/http.{Get, Post}
import server/routes/app/lists/views
import server/utils
import sql

import server/routes/app/lists/crud
import server/web
import wisp.{type Request, type Response}

pub fn handle_request(
  req: Request,
  ctx: web.Context,
  segments: List(String),
) -> Response {
  use req, maybe_user <- web.middleware(req, ctx)
  use req, user <- web.authenticate(req, ctx, maybe_user)
  use req, user <- web.authorize(req, user, [sql.Authorized, sql.Admin])

  case req.method, segments {
    Get, [] -> views.list_of_lists(ctx.db, user) |> utils.to_response
    Get, [id] -> {
      views.find_all_items(ctx.db, id)
      |> utils.to_response
    }
    Post, [id, "crud"] -> crud.add_item_to_list(req, ctx, id)
    Post, ["crud"] -> crud.create_list(req, ctx)

    _, _ -> wisp.not_found()
  }
}
