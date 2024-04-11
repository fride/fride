import gleam/io
import mug

pub fn main() {
  io.println("Hello from glanz_heos!")
  let assert Ok(socket) =
    mug.new("erlang-the-movie.example.com", port: 12_345)
    |> mug.timeout(milliseconds: 500)
    |> mug.connect()

  let assert Ok(Nil) = mug.send(socket, <<"Hello, Joe!\r\n":utf8>>)
}
