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

let testSharedStructure () =
  let testHamt2 = initq 20 in
  let testHamt3 = add testHamt2 "lasdkjfeoi" 100 in
  modify testHamt3 "7" 0;
  modify testHamt3 "lasdkjfeoi" (-1);
  Printf.printf "done\n";
  match options with
  | false -> export ~name:"hamt2" testHamt2; export ~name:"hamt3" testHamt3
  | true -> ()

let go () =
  (* testSharedStructure () *)
  match options with
  | false ->
    let hamt = initq 300 in
    export ~name:"hamt" hamt
  | true -> ()



let s = go ()
