import gleam/http.{Get}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/uri
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import pog
import server/auth/google
import server/auth/user
import server/utils
import server/web
import sql
import wisp.{type Request, type Response}

/// Router for all routes that match: /auth/...
/// 
pub fn router(
  req: Request,
  ctx: web.Context,
  segments: List(String),
) -> wisp.Response {
  // Read the user from the cookie and pass it to the routes
  let user = user.from_cookie(req)

  case req.method, segments {
    Get, ["callback"] -> handle_auth(req, ctx)
    Get, ["logout"] -> handle_logout(req)

    Get, ["auth-button"] -> {
      auth_button(user, ctx)
      |> utils.to_response
    }
    _, _ -> wisp.not_found()
  }
}

fn handle_logout(req: Request) -> Response {
  let resp = wisp.redirect("/")

  case wisp.get_cookie(req, "user_id", wisp.Signed) {
    // expire the cookie
    Ok(value) -> wisp.set_cookie(resp, req, "user_id", value, wisp.Signed, 0)
    Error(_) -> resp
  }
}

/// Log-in a user
/// 
pub fn handle_auth(req: Request, ctx: web.Context) -> Response {
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

      wisp.redirect("/")
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
      io.debug("No user found for ID " <> token_info.sub)
      let assert Ok(pog.Returned(rows_count, _rows)) =
        sql.insert_user(
          db,
          token_info.sub,
          token_info.name,
          token_info.email,
          email_verified,
        )

      io.debug(int.to_string(rows_count) <> " rows inserted!")
    }
    [_v, ..] -> {
      io.debug("User found for ID " <> token_info.sub)
    }
  }
}

pub fn auth_button(
  user: Option(user.User(user.Unverified)),
  ctx: web.Context,
) -> Element(Nil) {
  case user {
    Some(user) -> {
      let res = user.verify(user, ctx.db)

      case res {
        Ok(u) -> log_out_button(u, "/auth/logout")
        _ -> panic
        // TODO - Handle better
      }
    }
    None -> {
      ctx.google_creds
      |> auth_uri
      |> uri.to_string
      |> log_in_button
    }
  }
}

fn auth_uri(creds: google.AuthCredentials) {
  uri.Uri(
    scheme: Some("https"),
    userinfo: None,
    host: Some("accounts.google.com"),
    port: None,
    path: "o/oauth2/v2/auth",
    fragment: None,
    query: Some(
      uri.query_to_string([
        #("client_id", creds.client_id),
        #("redirect_uri", creds.redirect_uri),
        #("response_type", creds.response_type),
        #("access_type", creds.access_type),
        #("scope", creds.scope),
      ]),
    ),
  )
}

fn log_in_button(auth_href: String) -> Element(Nil) {
  html.a([attribute.href(auth_href)], [html.text("Log in with Google")])
}

fn log_out_button(u: user.User(user.Verified), href: String) -> Element(Nil) {
  html.div([], [
    html.text("Hello " <> u.name),
    html.a([attribute.href(href)], [html.text("Log out")]),
  ])
}
