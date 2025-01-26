import lustre/element.{type Element}
import server/layout/views as layout_views
import server/routes/auth/views as auth_views

// The main page for the app
pub fn page(user, ctx) -> Element(Nil) {
  layout_views.layout([auth_views.auth_button(user, ctx)])
}
