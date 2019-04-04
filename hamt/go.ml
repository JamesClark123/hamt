open Hamt
open Helper

let options =
  match (Array.length Sys.argv) > 1 with
  | false -> false
  | true ->
    begin
      match Sys.argv.(1) with
      | "-b" -> true
      | _ -> false
    end

let go () =
  let testHamt2 = initq 40 in
  match options with
  | false -> export testHamt2
  | true -> 1

let s = go ()
