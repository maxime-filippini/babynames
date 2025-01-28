import babynames/auth/user.{type User, type Verified}
import lustre/element.{type Element}
import pog

import app/pages/my_lists/views.{page as lists_page}

pub fn page(db: pog.Connection, user: User(Verified)) -> Element(Nil) {
  lists_page(user, db)
}
