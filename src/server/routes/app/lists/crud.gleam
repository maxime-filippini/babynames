import gleam/dynamic/decode
import gleam/http.{Post}
import pog
import sql
import youid/uuid

import server/web
import wisp.{type Request, type Response}

type ListCreateInput {
  ListCreateInput(name: String, user_id: String)
}

type ListItemCreateInput {
  ListItemCreateInput(user_id: String, value: String)
}

fn list_item_create_input_decoder() -> decode.Decoder(ListItemCreateInput) {
  use user_id <- decode.field("user_id", decode.string)
  use value <- decode.field("value", decode.string)
  decode.success(ListItemCreateInput(user_id:, value:))
}

fn list_create_input_decoder() -> decode.Decoder(ListCreateInput) {
  use name <- decode.field("name", decode.string)
  use user_id <- decode.field("user_id", decode.string)
  decode.success(ListCreateInput(name:, user_id:))
}

pub fn create_list(req: Request, ctx: web.Context) -> Response {
  use json <- wisp.require_json(req)
  use <- wisp.require_method(req, Post)

  // Decoding from JSON body
  let assert Ok(list_info) = decode.run(json, list_create_input_decoder())

  let assert Ok(pog.Returned(_count, _rows)) =
    sql.insert_list(ctx.db, list_info.name, list_info.user_id)

  wisp.response(201)
}

pub fn add_item_to_list(
  req: Request,
  ctx: web.Context,
  list_id: String,
) -> Response {
  use json <- wisp.require_json(req)
  use <- wisp.require_method(req, Post)
  let assert Ok(list_info) = decode.run(json, list_item_create_input_decoder())

  let assert Ok(list_uuid) = uuid.from_string(list_id)

  // TODO - Check that user is allowed to add a name

  let assert Ok(pog.Returned(_count, _rows)) =
    sql.insert_list_item(ctx.db, list_uuid, list_info.value)

  wisp.response(201)
}
