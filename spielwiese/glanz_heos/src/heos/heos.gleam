import gleam/io
import gleam/result
import gleam/json
import gleam/dynamic.{
  type DecodeError, type Dynamic, dynamic, field, int, list, optional,
  optional_field, string,
}
import heos/connection
import heos/command

pub fn main() {
  let assert Ok(socket) = connection.connect_to("192.168.178.34")
  let executor = connection.execute_command(socket, _)

  io.println("Hello from glanz_heos!")
  io.debug(command.get_player_infos(executor))

  io.println("Hello from glanz_heos!")
  io.debug(command.get_play_state(executor, 12))
  io.debug(command.get_play_state(executor, -1_428_708_007))
}
