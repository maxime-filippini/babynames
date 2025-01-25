import gleam/http.{Get}
import pages/index
import server/auth/router as auth_router
import server/utils
import server/web
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: web.Context) -> Response {
  use req <- web.middleware(req, ctx)

  case req.method, wisp.path_segments(req) {
    Get, [] ->
      index.page()
      |> utils.to_response

    Get, ["auth", ..segments] -> {
      auth_router.router(req, ctx, segments)
    }

    _, _ -> wisp.not_found()
  }
}
