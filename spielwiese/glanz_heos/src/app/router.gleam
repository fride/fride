import wisp.{type Request, type Response}
import app/web
import heos/command
import app/view

/// The HTTP request handler- your application!
/// 
pub fn handle_request(req: Request, context: web.Context) -> Response {
  // Apply the middleware stack for this request/response.
  use _req <- web.middleware(req)

  // Later we'll use templates, but for now a string will do.
  let body =
    command.get_player_infos(context.heos)
    |> view.display_or_error(view.show_player_list)

  // Return a 200 OK response with the body and a HTML content type.

  // context/
  wisp.html_response(body.1, body.0)
}
