import gleam/dynamic/decode
import pog

/// Runs the `insert_user` query
/// defined in `./src/sql/insert_user.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn insert_user(db, arg_1, arg_2, arg_3, arg_4) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  let query =
    "INSERT INTO users (user_id, name, email, email_verified)
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

/// A row you get from running the `get_random_names` query
/// defined in `./src/sql/get_random_names.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetRandomNamesRow {
  GetRandomNamesRow(rank: Int, name: String, pct: Float, year: Int)
}

/// Runs the `get_random_names` query
/// defined in `./src/sql/get_random_names.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_random_names(db, arg_1) {
  let decoder = {
    use rank <- decode.field(0, decode.int)
    use name <- decode.field(1, decode.string)
    use pct <- decode.field(2, decode.float)
    use year <- decode.field(3, decode.int)
    decode.success(GetRandomNamesRow(rank:, name:, pct:, year:))
  }

  let query =
    "SELECT *
FROM baby_names
ORDER BY RANDOM() LIMIT $1"

  pog.query(query)
  |> pog.parameter(pog.int(arg_1))
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
    name: String,
    email: String,
    email_verified: Bool,
    user_role: UserRole,
    role: UserRole,
    rank: Int,
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
    use name <- decode.field(1, decode.string)
    use email <- decode.field(2, decode.string)
    use email_verified <- decode.field(3, decode.bool)
    use user_role <- decode.field(4, user_role_decoder())
    use role <- decode.field(5, user_role_decoder())
    use rank <- decode.field(6, decode.int)
    decode.success(FindUserRow(
      user_id:,
      name:,
      email:,
      email_verified:,
      user_role:,
      role:,
      rank:,
    ))
  }

  let query =
    "SELECT *
FROM users
LEFT JOIN roles
    ON users.user_role = roles.role
WHERE
    1 = 1
    AND user_id = $1
    AND roles.role IS NOT NULL"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

// --- Enums -------------------------------------------------------------------

/// Corresponds to the Postgres `user_role` enum.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type UserRole {
  Authorized
  Unauthorized
  Admin
}

fn user_role_decoder() {
  use variant <- decode.then(decode.string)
  case variant {
    "authorized" -> decode.success(Authorized)
    "unauthorized" -> decode.success(Unauthorized)
    "admin" -> decode.success(Admin)
    _ -> decode.failure(Authorized, "UserRole")
  }
}
