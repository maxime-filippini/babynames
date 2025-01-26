import gleam/option.{type Option, None, Some}
import gleam/uri
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import server/auth/uris
import server/auth/user
import server/web

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
      |> uris.auth_uri
      |> uri.to_string
      |> log_in_button
    }
  }
}

pub fn log_in_button(auth_href: String) -> Element(Nil) {
  html.a([attribute.href(auth_href)], [html.text("Log in with Google")])
}

pub fn log_out_button(u: user.User(user.Verified), href: String) -> Element(Nil) {
  html.div([], [
    html.text("Hello " <> u.name),
    html.a([attribute.href(href)], [html.text("Log out")]),
  ])
}
