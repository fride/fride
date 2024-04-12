import lustre
import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html
import heos/command.{type PlayerInfo}
import gleam/list
import gleam/string_builder.{type StringBuilder}

pub fn show_player_list(players: List(PlayerInfo)) -> StringBuilder {
  let player_to_list_item = fn(player: PlayerInfo) {
    html.li([], [element.text(player.name)])
  }

  players
  |> list.map(player_to_list_item)
  |> html.ul([], _)
  |> layout
}

fn layout(content: Element(Nil)) -> StringBuilder {
  html.html([attribute("lang", "en"), attribute.class("theme-light")], [
    html.head([], [
      html.meta([attribute("charset", "utf-8")]),
      html.meta([
        attribute.name("viewport"),
        attribute("content", "width=device-width, initial-scale=1"),
      ]),
      html.title([], "Gleam Packages"),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/static/common.css"),
      ]),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/static/styles.css"),
      ]),
      html.link([
        attribute.rel("icon"),
        attribute.href("https://gleam.run/images/lucy/lucy.svg"),
      ]),
      html.script(
        [
          attribute.property("defer", True),
          attribute.src("https://plausible.io/js/plausible.js"),
          attribute("data-domain", "packages.gleam.run"),
        ],
        "",
      ),
      html.script(
        [attribute.type_("module"), attribute.src("/static/main.js")],
        "",
      ),
    ]),
    html.body([], [html.main([], [content])]),
  ])
  |> element.to_string_builder
  |> string_builder.prepend("<!DOCTYPE html>")
}

pub fn display_or_error(result: Result(a, b), view: fn(a) -> StringBuilder) {
  case result {
    Ok(ok) -> #(200, view(ok))
    Error(_) -> #(503, string_builder.from_string("<h1>Error!</h1>"))
  }
}
