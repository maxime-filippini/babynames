import app/layout
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn home_page() -> Element(Nil) {
  let body =
    html.div(
      [attribute.class("flex items-center justify-center w-full m-8 h-screen")],
      [
        html.a(
          [
            attribute.class(
              "px-8 py-4 bg-purple-300 hover:bg-purple-500 duration-500 rounded-lg text-bold text-3xl hover:text-white text-black",
            ),
            attribute.href("/app"),
          ],
          [html.text("Access the app")],
        ),
      ],
    )

  [body]
  |> layout.layout
}
