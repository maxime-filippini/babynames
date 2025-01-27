// TODO

import gleam/http.{Get}
import server/routes/admin/views
import server/utils
import server/web
import wisp.{type Request, type Response}

pub fn handle_request(
  req: Request,
  ctx: web.Context,
  segments: List(String),
) -> Response {
  use req, user <- web.middleware(req, ctx)

  case req.method, segments {
    Get, [] -> {
      views.admin_panel() |> utils.to_response
    }

    _, _ -> wisp.not_found()
  }
}
