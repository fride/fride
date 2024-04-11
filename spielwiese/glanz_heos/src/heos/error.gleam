import mug
import gleam/json
import gleam/dynamic

/// this is horrible!
pub type HeosError {
  NetworkError(cause: mug.Error)
  JsonError(cause: json.DecodeError)
  DecoderError(cause: List(dynamic.DecodeError))
}
