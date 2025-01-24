import gleam/http.{Get}
import gleam/string_tree
import server/web
import simplifile
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: web.Context) -> Response {
  use req <- web.middleware(req, ctx)
  let path = ctx.static_directory <> "/index.html"
  let assert Ok(html) = simplifile.read(path)

  case req.method, wisp.path_segments(req) {
    Get, [] ->
      html
      |> string_tree.from_string
      |> wisp.html_response(200)

    // method, ["contact", ..rest] -> contact.router(method, rest)
    _, _ -> wisp.not_found()
  }
}
// pub fn handle_form_submission(req: Request) -> Response {
//   use formdata <- wisp.require_form(req)

//   let result = {
//     use title <- result.try(list.key_find(formdata.values, "title"))
//     use name <- result.try(list.key_find(formdata.values, "name"))
//     let greeting =
//       "Hi, " <> wisp.escape_html(title) <> " " <> wisp.escape_html(name) <> "!"
//     Ok(greeting)
//   }

//   case result {
//     Ok(content) -> {
//       wisp.ok()
//       |> wisp.html_body(string_tree.from_string(content))
//     }
//     Error(_) -> {
//       wisp.bad_request()
//     }
//   }
// }
