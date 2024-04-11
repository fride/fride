import gleam/io
import gleam/regex
import gleam/list
import gleam/result
import gleam/int
import gleam/option

const lines = "
  März        15
  April       17
  Mai         18
  Juni         5
  July        16
  August      16
  September   19
  Oktober     13
  November    19
  Dezember    10
"

pub type Month {
  Month(name: String, days: Int, hours: Int)
  InvalidDays(name: String, days: String)
}

fn parse_month(matches: List(String)) {
  // the use expression looks a bit like scala for, but different.
  use name_of_month <- result.try(list.first(matches))
  use days_in_month_str <- result.try(list.at(matches, 1))
  use days_in_month <- result.map(int.parse(days_in_month_str))
  Month(name_of_month, days_in_month, days_in_month * 8)
}

pub fn main() {
  let assert Ok(re) = regex.from_string("([^ ]+) +([0-9]+)\n?")
  // crashes if from_string does not like the pattern.
  let result =
    regex.scan(re, lines)
    |> list.map(fn(match) { match.submatches })
    |> list.map(option.values)
    |> list.map(parse_month)
    |> result.values
  io.debug(result)
}
