import gleam/option.{type Option, None, Some}
import gleam/uri
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import server/auth/uris
import server/auth/user.{type Unverified, type User, type Verified}
import server/web

type NavItem {
  Home
  App
  Admin
}

pub fn auth_button(
  user: Option(user.User(user.Unverified)),
  ctx: web.Context,
) -> Element(Nil) {
  case user {
    Some(user) -> {
      let res = user.verify(user, ctx.db)

      case res {
        Ok(_) -> log_out_button("/auth/logout")
        _ -> panic
        // TODO - Handle better
      }
    }
    None -> {
      ctx.google_creds
      |> uris.auth_uri
      |> uri.to_string
      |> log_in_button
    }
  }
}

pub fn log_in_button(auth_href: String) -> Element(Nil) {
  html.a([attribute.href(auth_href)], [html.text("Log in with Google")])
}

pub fn log_out_button(href: String) -> Element(Nil) {
  html.div([], [html.a([attribute.href(href)], [html.text("Log out")])])
}

fn to_html(item: NavItem) -> Element(Nil) {
  let #(url, title) = case item {
    Home -> #("/", "Home")
    App -> #("/app", "App")
    Admin -> #("/admin", "Admin")
  }

  html.li([], [html.a([attribute.href(url)], [html.text(title)])])
}

fn nav_items(auth_button: Element(Nil), name: Element(Nil)) {
  html.ul(
    [attribute.class("flex p-4 gap-8 border border-gray-100 bg-gray-50")],
    [to_html(Home), to_html(App), to_html(Admin), auth_button, name],
  )
}

fn email_indicator(user: User(Verified)) -> Element(Nil) {
  html.p([], [html.text(user.email)])
}

pub fn nav_bar(
  maybe_user: Option(User(Unverified)),
  ctx: web.Context,
) -> Element(Nil) {
  let #(auth_button, name) = case maybe_user {
    Some(user) -> {
      let res = user.verify(user, ctx.db)

      case res {
        Ok(u) -> #(log_out_button("/auth/logout"), email_indicator(u))
        _ -> panic
        // TODO - Handle better
      }
    }
    None -> {
      let button =
        ctx.google_creds
        |> uris.auth_uri
        |> uri.to_string
        |> log_in_button

      #(button, html.div([], []))
    }
  }

  html.nav([attribute.class("")], [nav_items(auth_button, name)])
}

pub fn text(s: String) -> Element(Nil) {
  html.p([], [html.text(s)])
}
