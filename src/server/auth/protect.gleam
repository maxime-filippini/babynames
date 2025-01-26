import gleam/option.{None, Some}
import gleam/string_tree
import server/auth/user.{type Unverified, type User, type Verified}
import server/web
import sql.{type UserRole}
import wisp.{type Request, type Response}

fn unauthenticated(req: Request) -> Response {
  wisp.html_response(string_tree.from_string(""), 401)
}

fn unauthorized(req: Request) -> Response {
  wisp.html_response(string_tree.from_string(""), 403)
}
// pub fn authenticate(
//   req: Request,
//   ctx: web.Context,
//   handle_request: fn(wisp.Request, User(Verified)) -> Response,
// ) -> fn(Request) -> Response {
//   let user = user.from_cookie(req)

//   //   case user {
//   //     None -> unauthenticated
//   //     Some(u) -> {
//   //       case user.verify(u, ctx.db) {
//   //         Ok(u) -> handle_request(req, u)
//   //         Error(_) -> {

//   //         }
//   //       }
//   //     }
//   //   }

//   todo
// }

// pub fn authorize(
//   req: Request,
//   role: UserRole,
//   handle_request: fn(wisp.Request) -> Response,
// ) {
//   todo
// }
