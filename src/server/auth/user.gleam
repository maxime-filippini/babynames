import gleam/option.{type Option, None, Some}
import pog
import sql.{type UserRole, Unauthorized}
import wisp.{type Request}

// Those are phantom types, used to type-check whether a user has been
// verified or not.

pub type Unverified

pub type Verified

pub type User(a) {
  User(id: String, name: String, email: String, role: UserRole)
}

pub fn new(id: String) -> User(a) {
  User(id, "", "", Unauthorized)
}

pub fn from_cookie(req: Request) -> Option(User(Unverified)) {
  case wisp.get_cookie(req, "user_id", wisp.Signed) {
    Error(_) -> None
    Ok(v) -> Some(User(v, "", "", Unauthorized))
  }
}

pub fn verify(
  user: User(Unverified),
  db: pog.Connection,
) -> Result(User(Verified), Nil) {
  let assert Ok(pog.Returned(_rows_count, rows)) = sql.find_user(db, user.id)

  case rows {
    [] -> Error(Nil)
    [row, ..] -> {
      // The user is now verified
      let u: User(Verified) =
        User(row.user_id, row.name, row.email, row.user_role)
      Ok(u)
    }
  }
}
