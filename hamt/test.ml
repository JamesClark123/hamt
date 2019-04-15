open Core
open Core_bench
open Random

module M = Core.Map.Make(Int)
module H = Hashtbl.Make(Int)

let tests () =
  let trialsizes = [10;100;500;1000;5000;10000] in
  let ranrange = 1000000000 in

  (* Find Tests *)
  Command.run (Bench.make_command [
      Bench.Test.create_indexed
        ~name:"Map Find"
        ~args:trialsizes
        (fun len ->
           let keys = List.init len (fun x -> x * Random.int ranrange) in
           let keysArray = Array.of_list keys in
           let values = List.init len (fun x -> x * Random.int ranrange) in
           let pairs = match List.zip keys values with | Some p -> p | None -> failwith "error" in
           let map = M.of_alist_exn pairs in
           let key () = Array.get keysArray (Random.int len) in
           (* let map2 =  match M.add map key 0 with | `Ok a -> a | _ -> failwith "error" in *)
           Staged.stage (fun () -> ignore (M.find map (key()) )));
      Bench.Test.create_indexed
        ~name:"Hamt Find"
        ~args:trialsizes
        (fun len ->
           let keys = List.init len (fun x -> x * Random.int ranrange) in
           let keysArray = Array.of_list keys in
           let values = List.init len (fun x -> x * Random.int ranrange) in
           let pairs = match List.zip keys values with | Some p -> p | None -> failwith "error" in
           let hamt = Hamt.init pairs in
           let key () = Array.get keysArray (Random.int len) in
           Staged.stage (fun () -> ignore (Hamt.find hamt (key()) )));
      Bench.Test.create_indexed
        ~name:"Hashtbl Find"
        ~args:trialsizes
        (fun len ->
           let keys = List.init len (fun x -> x * Random.int ranrange) in
           let keysArray = Array.of_list keys in
           let values = List.init len (fun x -> x * Random.int ranrange) in
           let pairs = match List.zip keys values with | Some p -> p | None -> failwith "error" in
           let hashtbl = H.of_alist_exn pairs in
           let key () = Array.get keysArray (Random.int len) in
           Staged.stage (fun () -> ignore (H.find hashtbl (key()) )));
    ]);

  (* Insert Tests *)
  Command.run (Bench.make_command [
      Bench.Test.create_indexed
        ~name:"Map Insert"
        ~args:trialsizes
        (fun len ->
           let keys = List.init len (fun x -> x * Random.int ranrange) in
           let values = List.init len (fun x -> x * Random.int ranrange) in
           let pairs = match List.zip keys values with | Some p -> p | None -> failwith "error" in
           let map = Int.Map.of_alist_exn pairs in
           Staged.stage (fun () -> ignore (Map.add map (Random.int ranrange) (-1) )));
      Bench.Test.create_indexed
        ~name:"Hamt Insert"
        ~args:trialsizes
        (fun len ->
           let keys = List.init len (fun x -> x * Random.int ranrange) in
           let values = List.init len (fun x -> x * Random.int ranrange) in
           let pairs = match List.zip keys values with | Some p -> p | None -> failwith "error" in
           let hamt = Hamt.init pairs in
           Staged.stage (fun () -> ignore (Hamt.add hamt (Random.int ranrange) (-1) )));
      Bench.Test.create_indexed
        ~name:"Hashtbl Insert"
        ~args:trialsizes
        (fun len ->
           let keys = List.init len (fun x -> x * Random.int ranrange) in
           let values = List.init len (fun x -> x * Random.int ranrange) in
           let pairs = match List.zip keys values with | Some p -> p | None -> failwith "error" in
           let hashtbl = H.of_alist_exn pairs in
           Staged.stage (fun () -> ignore (H.add hashtbl (Random.int ranrange) (-1) )));
    ]);

  (* Make Tests *)
  Command.run (Bench.make_command [
      Bench.Test.create_indexed
        ~name:"Map Make"
        ~args:[10;100;500;1000;5000;10000]
        (fun len ->
           let keys = List.init len (fun x -> x * Random.int ranrange) in
           let values = List.init len (fun x -> x * Random.int ranrange) in
           let pairs = match List.zip keys values with | Some p -> p | None -> failwith "error" in
           Staged.stage (fun () -> ignore (Int.Map.of_alist_exn pairs)));
      Bench.Test.create_indexed
        ~name:"Hamt Make"
        ~args:[10;100;500;1000;5000;10000]
        (fun len ->
           let keys = List.init len (fun x -> x * Random.int ranrange) in
           let values = List.init len (fun x -> x * Random.int ranrange) in
           let pairs = match List.zip keys values with | Some p -> p | None -> failwith "error" in
           Staged.stage (fun () -> ignore (Hamt.init pairs)));
      Bench.Test.create_indexed
        ~name:"Hashtbl Make"
        ~args:[10;100;500;1000;5000;10000]
        (fun len ->
           let keys = List.init len (fun x -> x * Random.int ranrange) in
           let values = List.init len (fun x -> x * Random.int ranrange) in
           let pairs = match List.zip keys values with | Some p -> p | None -> failwith "error" in
           Staged.stage (fun () -> ignore (H.of_alist_exn pairs)));
    ])
