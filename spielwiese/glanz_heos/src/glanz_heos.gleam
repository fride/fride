import gleam/erlang/process
import mist
import wisp
import app/router
import heos/connection
import app/web

pub fn main() {
  // This sets the logger to print INFO level logs, and other sensible defaults
  // for a web application.
  wisp.configure_logger()

  // Here we generate a secret key, but in a real application you would want to
  // load this from somewhere so that it is not regenerated on every restart.
  let secret_key_base = wisp.random_string(64)

  let assert Ok(socket) = connection.connect_to("192.168.178.34")
  let executor = connection.execute_command(socket, _)
  let context = web.Context(executor)

  // Start the Mist web server.
  let assert Ok(_) =
    wisp.mist_handler(router.handle_request(_, context), secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  // The web server runs in new Erlang process, so put this one to sleep while
  // it works concurrently.
  process.sleep_forever()
}
