import elements
import lustre/attribute.{attribute as attr}
import lustre/element.{type Element}
import lustre/element/html

pub fn page() -> Element(Nil) {
  html.html([attr("lang", "en")], [
    elements.head("Baby names"),
    html.body([], [
      // For now probably OK since the state of the button depends on user
      html.div(
        [attr("hx-trigger", "load"), attr("hx-get", "/auth/auth-button")],
        [],
      ),
    ]),
  ])
}
