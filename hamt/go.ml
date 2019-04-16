open Hamt
open Helper
open Test
open Core

let options =
  let help = "to print a hamt structure call ./go -p [size] where size is the number of elements in the hamt\nTo see performance tests compared to Core's Map and Hashtbl call ./go \n" in
  if Array.length Sys.argv = 1 then ignore(tests ~trialsizes:[500;1000;5000;10000;20000] ()) else
    match Sys.argv.(1) with
    | "-p" ->
      if Array.length Sys.argv < 3 then Printf.printf "%s" "expected a size\n" else
        let size = int_of_string Sys.argv.(2) in
        let keys = List.init size (fun x -> x) in
        let values = List.init size (fun x -> x) in
        let pairs = match List.zip keys values with | Some l -> l | None -> failwith "error making list" in
        let hamt = Hamt.of_alist pairs in
        export hamt
    | _ -> Printf.printf "%s" help

(* let testSharedStructure () =
   let testHamt2 = initq 20 in
   let testHamt3 = add testHamt2 "lasdkjfeoi" 100 in
   modify testHamt3 "7" 0;
   modify testHamt3 "lasdkjfeoi" (-1);
   Printf.printf "done\n";
   match options with
   | false -> export ~name:"hamt2" testHamt2; export ~name:"hamt3" testHamt3
   | true -> () *)

let go () = options

let s = go ()
