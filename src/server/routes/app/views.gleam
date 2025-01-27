import lustre/element.{type Element}
import pog
import server/auth/user.{type User, type Verified}

import server/routes/app/lists/views.{page as lists_page}

pub fn page(db: pog.Connection, user: User(Verified)) -> Element(Nil) {
  lists_page(user, db)
}
