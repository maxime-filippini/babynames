import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

type NavItem {
  Home
  Test
}

fn to_html(item: NavItem) -> Element(Nil) {
  let #(url, title) = case item {
    Home -> #("/", "Home")
    Test -> #("/test", "Test")
  }

  html.li([], [html.a([attribute.href(url)], [html.text(title)])])
}

fn nav_items() {
  html.ul(
    [attribute.class("flex p-4 gap-8 border border-gray-100 bg-gray-50")],
    [to_html(Home), to_html(Test)],
  )
}

pub fn nav_bar() -> Element(Nil) {
  html.nav([attribute.class("")], [nav_items()])
}

pub fn text(s: String) -> Element(Nil) {
  html.p([], [html.text(s)])
}
