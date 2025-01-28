// import lustre/attribute.{attribute as attr}
// import lustre/element.{type Element}
// import lustre/element/html
// import server/elements

// // The main page for the app
// pub fn layout(body: List(Element(Nil))) -> Element(Nil) {
//   html.html([attr("lang", "en")], [
//     elements.head("Baby names"),
//     html.body([attribute.class("flex flex-col gap-8 w-full p-8")], body),
//   ])
// }

// pub fn main_page() -> Element(Nil) {
//   layout([
//     html.div([attribute.class("flex items-center justify-center w-full")], [
//       html.a(
//         [
//           attribute.class(
//             "px-4 py-2 bg-purple-300 hover:bg-purple-500 duration-500 rounded-lg text-bold hover:text-white text-black",
//           ),
//           attribute.href("/app"),
//         ],
//         [html.text("Access the app")],
//       ),
//     ]),
//   ])
// }
