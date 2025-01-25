import lustre/attribute.{attribute as attr}
import lustre/element.{type Element}
import lustre/element/html

pub fn page() -> Element(Nil) {
  html.html([attr("lang", "en")], [
    html.head([], [
      html.meta([attr("charset", "UTF-8")]),
      html.meta([
        attr("content", "width=device-width, initial-scale=1.0"),
        attribute.name("viewport"),
      ]),
      html.title([], "Document"),
      html.script(
        [
          attribute.type_("text/javascript"),
          attribute.src("static/htmx.min.js"),
        ],
        "",
      ),
      html.link([
        attribute.href("static/styles.css"),
        attribute.rel("stylesheet"),
      ]),
    ]),
    html.body([], [
      html.div(
        [attr("hx-trigger", "load"), attr("hx-get", "/auth/auth-button")],
        [],
      ),
    ]),
  ])
}
