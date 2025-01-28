import app/auth/views
import babynames/auth/cookie
import babynames/auth/google
import babynames/auth/user.{type Unverified, type User}
import babynames/utils
import babynames/web
import gleam/http.{Get}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/uri
import pog
import sql
import wisp.{type Request, type Response}

pub fn route_request(
  req: Request,
  ctx: web.Context,
  _maybe_user: Option(User(Unverified)),
  segments: List(String),
) -> Response {
  case req.method, segments {
    Get, ["login"] -> handle_login(req, ctx)
    Get, ["callback"] -> handle_auth(req, ctx)
    Get, ["logout"] -> handle_logout(req)
    _, _ -> wisp.not_found()
  }
}

fn handle_login(_req: Request, ctx: web.Context) -> Response {
  ctx
  |> views.login_page()
  |> utils.to_response
}

fn handle_logout(req: Request) -> Response {
  let resp = wisp.redirect("/")

  case wisp.get_cookie(req, "user_id", wisp.Signed) {
    Ok(_value) -> cookie.with_invalidated_user_cookie(req, resp)
    Error(_) -> resp
  }
}

fn handle_auth(req: Request, ctx: web.Context) -> Response {
  case req.query {
    None -> wisp.not_found()
    Some(v) -> {
      let assert Ok(qry) = uri.parse_query(v)
      let assert Ok(code) = list.key_find(qry, "code")

      // Build the object obtained from sending an authorise request to the 
      // Google OAuth service
      let auth_obj = google.request_token(ctx.google_creds, code)

      // Use the Google token_info service to "validate" the token
      // (this is not real validation)
      let token_info = google.request_token_info(auth_obj.id_token)

      // TODO: This should be part of the decoding
      let email_verified = case token_info.email_verified {
        "true" -> True
        _ -> False
      }

      insert_user_if_not_in_db(ctx.db, token_info, email_verified)

      wisp.redirect("/app")
      |> wisp.set_cookie(
        req,
        "user_id",
        token_info.sub,
        security: wisp.Signed,
        max_age: 24 * 60 * 60,
      )
    }
  }
}

fn insert_user_if_not_in_db(
  db: pog.Connection,
  token_info: google.TokenInfo,
  email_verified: Bool,
) {
  let assert Ok(pog.Returned(_rows_count, rows)) =
    sql.find_user(db, token_info.sub)

  case rows {
    [] -> {
      let assert Ok(pog.Returned(rows_count, _rows)) =
        sql.insert_user(
          db,
          token_info.sub,
          token_info.name,
          token_info.email,
          email_verified,
        )

      io.debug(int.to_string(rows_count) <> " rows inserted!")

      Nil
    }
    [_v, ..] -> Nil
  }
}
