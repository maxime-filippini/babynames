import gleam/dynamic/decode
import gleam/option.{type Option}
import pog
import youid/uuid.{type Uuid}

/// A row you get from running the `find_user` query
/// defined in `./src/sql/find_user.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindUserRow {
  FindUserRow(id: Option(Uuid), name: Option(String), email: Option(String))
}

/// Runs the `find_user` query
/// defined in `./src/sql/find_user.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn find_user(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, decode.optional(uuid_decoder()))
    use name <- decode.field(1, decode.optional(decode.string))
    use email <- decode.field(2, decode.optional(decode.string))
    decode.success(FindUserRow(id:, name:, email:))
  }

  let query = "SELECT *
FROM users
WHERE id = $1"

  pog.query(query)
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

// --- Encoding/decoding utils -------------------------------------------------

/// A decoder to decode `Uuid`s coming from a Postgres query.
///
fn uuid_decoder() {
  use bit_array <- decode.then(decode.bit_array)
  case uuid.from_bit_array(bit_array) {
    Ok(uuid) -> decode.success(uuid)
    Error(_) -> decode.failure(uuid.v7(), "uuid")
  }
}
