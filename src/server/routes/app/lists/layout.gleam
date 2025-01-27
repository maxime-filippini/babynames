import lustre/attribute.{attribute as attr}
import lustre/element.{type Element}
import lustre/element/html
import server/elements

import server/routes/app/layout.{layout as app_layout}

pub fn layout(body: List(Element(Nil))) {
  app_layout(body)
}
