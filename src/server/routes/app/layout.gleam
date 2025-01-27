import lustre/attribute.{attribute as attr}
import lustre/element.{type Element}
import lustre/element/html
import server/elements

pub fn layout(body: List(Element(Nil))) {
  html.html([attr("lang", "en")], [
    elements.head("The App!"),
    html.body([attribute.class("h-screen")], body),
  ])
}
