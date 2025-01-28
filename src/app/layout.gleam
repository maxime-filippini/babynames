import babynames/elements
import lustre/attribute.{attribute as attr}
import lustre/element.{type Element}
import lustre/element/html

pub fn layout(body: List(Element(Nil))) {
  html.html([attr("lang", "en")], [
    elements.head("Baby names"),
    html.body([attribute.class("h-screen")], body),
  ])
}
