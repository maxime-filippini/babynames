import gleam/http.{Get}
import server/routes/admin/router as admin_router
import server/routes/app/router as app_router
import server/routes/auth/router as auth_router
import server/routes/index/router as index_router

import server/web
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: web.Context) -> Response {
  use req, _user <- web.middleware(req, ctx)

  case req.method, wisp.path_segments(req) {
    Get, ["auth", ..segments] -> auth_router.handle_request(req, ctx, segments)

    Get, ["app", ..segments] -> app_router.handle_request(req, ctx, segments)

    Get, ["admin", ..segments] ->
      admin_router.handle_request(req, ctx, segments)

    Get, segments -> index_router.handle_request(req, ctx, segments)
    _, _ -> wisp.not_found()
  }
}
