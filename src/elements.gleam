import lustre/attribute.{attribute as attr}
import lustre/element.{type Element}
import lustre/element/html

pub fn stylesheet(file_name: String) -> Element(Nil) {
  html.link([
    attribute.href("static/" <> file_name),
    attribute.rel("stylesheet"),
  ])
}

pub fn htmx() -> Element(Nil) {
  html.script(
    [attribute.type_("text/javascript"), attribute.src("static/htmx.min.js")],
    "",
  )
}

pub fn head(title: String) -> Element(Nil) {
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

pub fn emoji_favicon(emoji: String) -> Element(Nil) {
  let left =
    "data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>"
  let right = "</text></svg>"

  html.link([attribute.href(left <> emoji <> right), attribute.rel("icon")])
}
