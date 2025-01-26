import lustre/element.{type Element}
import server/layout/views as layout_views

// The main page for the app
pub fn page(maybe_user, ctx) -> Element(Nil) {
  layout_views.layout([], maybe_user, ctx)
}
