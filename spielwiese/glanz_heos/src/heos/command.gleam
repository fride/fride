import gleam/result.{try}
import gleam/io
import gleam/json
import gleam/dynamic.{
  type DecodeError, type Dynamic, dynamic, field, int, list, optional,
  optional_field, string,
}
import heos/error
import heos/connection.{type HeosResponse}
import gleam/option.{type Option, None, Some}
import gleam/bit_array
import gleam/int
import gleam/uri.{parse_query}
import gleam/list.{find_map}

pub type PlayerInfo {
  PlayerInfo(name: String, pid: Int, version: Option(String))
}

pub type PlayState {
  Play
  Pause
  Stop
}

pub type PlayerPlayState {
  PlayerPlayState(state: PlayState, player_id: Int)
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

pub fn get_play_state(
  connection: fn(BitArray) -> Result(HeosResponse, error.HeosError),
  id,
) {
  let command =
    bit_array.from_string(
      "heos://player/get_play_state?pid=" <> int.to_string(id) <> "\r\n",
    )
  use response <- try(connection(command))
  use querie_params <- try(message_to_query(response.heos.message))
  use pid <- try(parse_in_query(querie_params, parse_int("pid", _)))
  use state <- try(parse_in_query(querie_params, parse_play_state))
  Ok(PlayerPlayState(state, pid))
}

fn message_to_query(message) {
  parse_query(message)
  |> result.map_error(fn(error) { error.Ooops(message) })
}

fn parse_response(response: HeosResponse, decoder) -> Result(a, error.HeosError) {
  case response.payload {
    None -> Error(error.Ooops("No payload found"))
    Some(payload) ->
      decoder(payload)
      |> result.map_error(fn(e) { error.DecoderError(e) })
  }
}

// This is the ugly part, quering uri strings! :D
fn parse_int(name, tuple) {
  case tuple {
    #(n, str) if n == name ->
      result.map_error(int.parse(str), fn(error) {
        error.Ooops("Can not parse '" <> str <> "'' as int.")
      })
    _ -> Error(error.Ooops("No parameter '" <> name <> "' found."))
  }
}

fn parse_str(name) {
  fn(tuple) {
    case tuple {
      #(n, str) if n == name -> Ok(str)
      _ -> Error(error.Ooops("No parameter '" <> name <> "' found."))
    }
  }
}

fn parse_in_query(query_parameters, parser) -> Result(a, error.HeosError) {
  find_map(query_parameters, parser)
  |> result.replace_error(error.Ooops("BUUM"))
}

fn parse_play_state(tuple) {
  parse_str("state")(tuple)
  |> result.then(play_state_from_str)
}

fn play_state_from_str(str) {
  case str {
    "play" -> Ok(Play)
    "pause" -> Ok(Pause)
    "stop" -> Ok(Stop)
    _ -> Error(error.Ooops("BUUM"))
  }
}
