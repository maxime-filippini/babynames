import gleam/http.{Get}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/uri
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import pog
import server/auth/google
import server/utils
import server/web
import sql
import wisp.{type Request, type Response}

pub fn router(
  req: Request,
  ctx: web.Context,
  segments: List(String),
) -> wisp.Response {
  case req.method, segments {
    Get, ["callback"] -> handle_auth(req, ctx)
    Get, ["button"] ->
      auth_button(ctx.google_creds)
      |> utils.to_response
    _, _ -> wisp.not_found()
  }
}

/// Create a JWT from the code and send it back as a cookie
pub fn handle_auth(req: Request, ctx: web.Context) -> Response {
  case req.query {
    None -> wisp.not_found()
    Some(v) -> {
      let assert Ok(qry) = uri.parse_query(v)
      let assert Ok(code) = list.key_find(qry, "code")

      let auth_obj = google.request_token(ctx.google_creds, code)

      // We have parsed the Google response into our object

      // We now can grab the information from the id_token using another Google endpoint.
      // Normally, we would decode it, but Gleam doesn't have RS256 implemented. We could
      // also consider having a microservice to do that decoding.
      let token_info = google.request_token_info(auth_obj.id_token)

      // TODO: This should be part of the decoding
      let email_verified = case token_info.email_verified {
        "true" -> True
        _ -> False
      }

      // If the user is not in our user table, we add her
      let assert Ok(pog.Returned(_rows_count, rows)) =
        sql.find_user(ctx.db, token_info.sub)

      case rows {
        [] -> {
          io.debug("No user found for ID " <> token_info.sub)
          let assert Ok(pog.Returned(rows_count, _rows)) =
            sql.insert_user(
              ctx.db,
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

      // We now put the relevant information into signed cookies
      let cookie_age = 24 * 60 * 60

      wisp.redirect("/")
      |> wisp.set_cookie(
        req,
        "user_id",
        token_info.sub,
        security: wisp.Signed,
        max_age: cookie_age,
      )
    }
  }
}

pub fn auth_button(creds: google.AuthCredentials) -> Element(Nil) {
  let auth_uri =
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

  html.a([attribute.href(uri.to_string(auth_uri))], [
    html.text("Log in with Google"),
  ])
}
