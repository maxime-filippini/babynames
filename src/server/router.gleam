import gleam/http.{Get}
import server/routes/admin/router as admin_router
import server/routes/app/router as app_router
import server/routes/auth/router as auth_router

import server/utils
import server/views

import server/web
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: web.Context) -> Response {
  use req, _user <- web.middleware(req, ctx)

  case req.method, wisp.path_segments(req) {
    Get, [] ->
      views.main_page()
      |> utils.to_response

    _, ["app", ..segments] -> app_router.handle_request(req, ctx, segments)
    _, ["auth", ..segments] -> auth_router.handle_request(req, ctx, segments)
    _, ["admin", ..segments] -> admin_router.handle_request(req, ctx, segments)

    // Get, segments -> index_router.handle_request(req, ctx, segments)
    _, _ -> wisp.not_found()
  }
}
