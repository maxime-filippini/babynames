import app/api/router as api_router
import app/auth/router as auth_router
import app/pages/router as page_router
import app/views
import babynames/utils
import babynames/web
import wisp.{type Request, type Response}

pub fn route_request(req: Request, ctx: web.Context) -> Response {
  // No authentication is taking place here
  use req, maybe_user <- web.middleware(req, ctx)

  case wisp.path_segments(req) {
    [] -> views.home_page() |> utils.to_response
    ["app", ..rest] -> page_router.route_request(req, ctx, maybe_user, rest)
    ["api", ..rest] -> api_router.route_request(req, ctx, maybe_user, rest)
    ["auth", ..rest] -> auth_router.route_request(req, ctx, maybe_user, rest)

    _ -> wisp.not_found()
  }
}
