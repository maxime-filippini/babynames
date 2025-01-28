import babynames/attributes
import babynames/auth/user.{type User, type Verified}
import babynames/elements
import gleam/list
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import pog
import sql
import youid/uuid

pub fn get_all_lists_for_user(db: pog.Connection, user: User(Verified)) {
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

pub fn get_list_for_user(db: pog.Connection, list_id: String) {
  todo
}

pub fn get_list_items(db: pog.Connection, list_id: String) {
  let assert Ok(id) = uuid.from_string(list_id)
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

fn item_entry_in_list_of_list_items(item: sql.FindListItemsRow) -> Element(a) {
  html.div([], [html.p([], [item.value |> html.text])])
}

fn list_entry_in_lol(item: sql.GetListsRow) -> Element(a) {
  let item_id =
    item.id
    |> uuid.to_string

  html.div([], [
    elements.button(
      [
        attributes.hx_get("/api/lists/" <> item_id),
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
