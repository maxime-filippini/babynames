import babynames/auth/uris
import babynames/web
import gleam/uri
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn login_page(ctx: web.Context) -> Element(Nil) {
  ctx.google_creds
  |> uris.auth_uri
  |> uri.to_string
  |> log_in_button
}

fn log_in_button(auth_href: String) -> Element(Nil) {
  html.a([attribute.href(auth_href)], [html.text("Log in with Google")])
}

fn log_out_button(href: String) -> Element(Nil) {
  html.div([], [html.a([attribute.href(href)], [html.text("Log out")])])
}
