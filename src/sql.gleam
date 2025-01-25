import gleam/dynamic/decode
import gleam/option.{type Option}
import pog

/// Runs the `insert_user` query
/// defined in `./src/sql/insert_user.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn insert_user(db, arg_1, arg_2, arg_3, arg_4) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  let query = "INSERT INTO users (user_id, name, email, email_verified)
VALUES (
    $1, $2, $3, $4
)"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.parameter(pog.bool(arg_4))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `find_user` query
/// defined in `./src/sql/find_user.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindUserRow {
  FindUserRow(
    user_id: String,
    name: Option(String),
    email: Option(String),
    email_verified: Option(Bool),
  )
}

/// Runs the `find_user` query
/// defined in `./src/sql/find_user.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn find_user(db, arg_1) {
  let decoder = {
    use user_id <- decode.field(0, decode.string)
    use name <- decode.field(1, decode.optional(decode.string))
    use email <- decode.field(2, decode.optional(decode.string))
    use email_verified <- decode.field(3, decode.optional(decode.bool))
    decode.success(FindUserRow(user_id:, name:, email:, email_verified:))
  }

  let query = "SELECT *
FROM users
WHERE user_id = $1"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}
