import gleam/result.{map_error}
import mug.{type Socket}
import heos/error.{type HeosError}
import gleam/io
import gleam/dynamic.{type Dynamic, dynamic, field, optional_field, string}
import gleam/json

pub type HeosResponse {
  HeosResponse(heos: HeosResponseHeader, payload: Dynamic)
}

pub type HeosResponseHeader {
  HeosResponseHeader(name: String, result: String, message: String)
}

fn from_io_error(cause) {
  error.NetworkError(cause)
}

pub fn connect_to(address) -> Result(Socket, HeosError) {
  mug.new(address, port: 1255)
  |> mug.timeout(milliseconds: 500)
  |> mug.connect()
  |> map_error(from_io_error)
}

fn send_line(socket: Socket, command) {
  mug.send(socket, command)
  |> map_error(from_io_error)
}

fn receive_line(socket: Socket) {
  mug.receive(socket, timeout_milliseconds: 200)
  |> map_error(from_io_error)
}

pub fn execute_command(
  socket: Socket,
  command,
) -> Result(HeosResponse, error.HeosError) {
  use _ <- result.try(send_line(socket, command))
  use packet <- result.try(receive_line(socket))
  io.debug(packet)
  parse_heos_response(packet)
}

fn parse_heos_response(response) {
  let header_decoder =
    dynamic.decode3(
      HeosResponseHeader,
      field("command", of: string),
      field("result", of: string),
      field("message", of: string),
    )
  let decoder =
    dynamic.decode2(
      HeosResponse,
      field("heos", of: header_decoder),
      field("payload", of: dynamic),
    )
  json.decode_bits(response, decoder)
  |> map_error(fn(error) { error.JsonError(error) })
}
