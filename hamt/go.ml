open Hamt
open Helper

let go () =
  let testHamt2 = initq 40 in
  Printf.printf "shiftvalue: %d\n" shiftvalue;
  export testHamt2

let s = go ()
