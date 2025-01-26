// TODO

import gleam/http.{Get}
import server/routes/app/views
import server/utils
import server/web
import sql
import wisp.{type Request, type Response}

pub fn handle_request(
  req: Request,
  ctx: web.Context,
  segments: List(String),
) -> Response {
  use req, maybe_user <- web.middleware(req, ctx)
  use req, user <- web.authenticate(req, ctx, maybe_user)
  use req, _user <- web.authorize(req, user, [sql.Admin, sql.Authorized])

  case req.method, segments {
    Get, [] -> {
      views.main() |> utils.to_response
    }

    _, _ -> wisp.not_found()
  }
}
