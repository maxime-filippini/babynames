import gleam/option.{type Option}
import lustre/attribute.{attribute as attr}
import lustre/element.{type Element}
import lustre/element/html
import server/auth/user.{type Unverified, type User}
import server/layout/elements
import server/web

pub fn layout(
  body: List(Element(Nil)),
  maybe_user: Option(User(Unverified)),
  ctx: web.Context,
) {
  html.html([attr("lang", "en")], [
    head("Baby names"),
    html.body([], [elements.nav_bar(maybe_user, ctx), ..body]),
  ])
}

pub fn stylesheet(file_name: String) -> Element(Nil) {
  html.link([
    attribute.href("static/" <> file_name),
    attribute.rel("stylesheet"),
  ])
}

fn htmx() -> Element(Nil) {
  html.script(
    [attribute.type_("text/javascript"), attribute.src("static/htmx.min.js")],
    "",
  )
}

fn head(title: String) -> Element(Nil) {
  html.head([], [
    html.meta([attr("charset", "UTF-8")]),
    html.meta([
      attr("content", "width=device-width, initial-scale=1.0"),
      attribute.name("viewport"),
    ]),
    htmx(),
    emoji_favicon("👶"),
    stylesheet("styles.css"),
    html.title([], title),
  ])
}

fn emoji_favicon(emoji: String) -> Element(Nil) {
  let left =
    "data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>"
  let right = "</text></svg>"

  html.link([attribute.href(left <> emoji <> right), attribute.rel("icon")])
}
