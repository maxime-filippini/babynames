import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import pog
import server/attributes
import server/elements
import sql
import youid/uuid

import server/auth/user
import server/routes/app/lists/layout.{layout}

// List page
pub fn page(user: user.User(user.Verified), db: pog.Connection) {
  let name =
    user.name
    |> string.split(" ")
    |> list.map(string.capitalise)
    |> string.join(" ")

  let lists =
    html.div([], [
      elements.h2("Your lists:"),
      html.div([attribute.class("mb-4")], []),
      list_of_lists(db, user),
    ])

  let body = [
    html.div([attribute.class("flex flex-col p-8 gap-4 h-full")], [
      elements.h1("👋 Hello " <> name <> "!"),
      html.div([], [html.p([], [html.text("(" <> user.email <> ")")])]),
      html.div([attribute.class("w-full h-full flex gap-4")], [
        html.div([attribute.class("w-1/2 h-full bg-slate-300 rounded-lg p-4")], [
          lists,
        ]),
        html.div(
          [attribute.class("w-1/2 h-full bg-violet-200 rounded-lg p-4")],
          [html.div([attribute.id("list-items")], [])],
        ),
      ]),
    ]),
  ]

  body
  |> layout
}

// Elements on the list page

fn list_entry_in_lol(item: sql.GetListsRow) -> Element(a) {
  let item_id =
    item.id
    |> uuid.to_string

  html.div([], [
    elements.button(
      [
        attributes.hx_get("/app/lists/" <> item_id),
        attributes.hx_target("#list-items"),
        attribute.class("flex gap-2"),
      ],
      [
        html.p([], [item.name |> html.text]),
        html.p([attribute.class("italic")], [html.text("(" <> item_id <> ")")]),
      ],
    ),
  ])
}

fn item_entry_in_list_of_list_items(item: sql.FindListItemsRow) -> Element(a) {
  html.div([], [html.p([], [item.value |> html.text])])
}

pub fn list_of_lists(
  db: pog.Connection,
  user: user.User(user.Verified),
) -> Element(a) {
  let assert Ok(pog.Returned(_count, rows)) = sql.get_lists(db, user.id)

  case rows {
    [] -> html.p([], [html.text("Nothing!")])
    _ -> {
      html.div(
        [attribute.class("flex flex-col gap-4")],
        rows |> list.map(list_entry_in_lol),
      )
    }
  }
}

pub fn get_one(db: pog.Connection, id: uuid.Uuid) -> Option(sql.FindListRow) {
  let assert Ok(pog.Returned(_count, rows)) = sql.find_list(db, id)

  case rows {
    [] -> None
    [item, ..] -> Some(item)
  }
}

pub fn find_all_items(db: pog.Connection, id: String) -> Element(a) {
  let assert Ok(id) = uuid.from_string(id)
  let assert Ok(pog.Returned(_count, rows)) = sql.find_list_items(db, id)

  case rows {
    [] -> html.p([], [html.text("Empty!")])
    _ -> {
      html.div(
        [attribute.class("flex flex-col gap-4")],
        rows |> list.map(item_entry_in_list_of_list_items),
      )
    }
  }
}
