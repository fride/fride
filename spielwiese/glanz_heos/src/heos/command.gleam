import gleam/result.{try}
import gleam/io
import gleam/json
import gleam/dynamic.{
  type DecodeError, type Dynamic, dynamic, field, int, list, optional,
  optional_field, string,
}
import heos/error
import heos/connection.{type HeosResponse}
import gleam/option.{type Option}

pub type PlayerInfo {
  PlayerInfo(name: String, pid: Int, version: Option(String))
}

pub fn get_player_infos(
  connection: fn(BitArray) -> Result(HeosResponse, error.HeosError),
) -> Result(List(PlayerInfo), error.HeosError) {
  let player_info_decoder =
    dynamic.decode3(
      PlayerInfo,
      field("name", of: string),
      field("pid", of: int),
      optional_field("version", of: string),
    )

  use response <- try(connection(<<"heos://player/get_players\r\n":utf8>>))
  use player_infos <- try(parse_response(response, list(player_info_decoder)))
  Ok(player_infos)
}

fn parse_response(response: HeosResponse, decoder) -> Result(a, error.HeosError) {
  decoder(response.payload)
  |> result.map_error(fn(e) { error.DecoderError(e) })
}
