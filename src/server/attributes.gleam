import lustre/attribute.{attribute as attr}

pub fn hx_get(endpoint: String) {
  attr("hx-get", endpoint)
}

pub fn hx_target(selector: String) {
  attr("hx-target", selector)
}
