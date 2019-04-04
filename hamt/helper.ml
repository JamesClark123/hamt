(* file: hamt.ml
   author: James Clark

   This file contains a simple implementation of the HAMT data structure

*)
open Printf
open Random
open Sys
open Hamt

(* type ('a, 'b) printT = SomeHAMT of ('a, 'b) hamt
                     | NoHAMT of int *)

type outputT = Edge of int * tree
             | Value of int
             | Empty
and tree = outputT list
(*
let rec print hamt =
  let isAllEmpty l = List.fold_right (fun x y -> match x with | NoHAMT i -> 0 + y | _ -> 1 + y) l 0 in
  let p (hamt : ('a, 'b) hamt) =
    match hamt with
    | ArrayNode _ -> Printf.printf "N "
    | Entry {hash; key; value} -> Printf.printf "%d " value
    | CollisionNode _ -> Printf.printf "C "
    | Empty -> Printf.printf "E "
  in
  let rec printBlanks i =
    Printf.printf "_"
    (* match i with
       | 0 -> Printf.printf ""
       | i -> Printf.printf "|"; printBlanks (i-1) *)
  in
  let rec printLevel hamt_list =
    match hamt_list with
    | [] -> []
    | SomeHAMT ArrayNode {arr; shift} :: rest -> Array.iter (fun x -> p x) arr
                                               ; Printf.printf "  "
                                               ; Array.fold_right (fun x l -> SomeHAMT x :: l) arr (printLevel rest)
    | SomeHAMT Entry {hash; key; value} :: rest -> (*p (List.hd hamt_list)
                                                     ;*) NoHAMT 1 :: (printLevel rest)
    | SomeHAMT CollisionNode {ahash; hmes} :: rest -> List.iter (fun (key, value) -> Printf.printf "%d " value) hmes
                                                    ; NoHAMT 1 :: (printLevel rest)
    | SomeHAMT Empty :: rest -> printBlanks 1; NoHAMT 1 :: printLevel(rest)
    | NoHAMT i :: rest -> printBlanks i; (*NoHAMT (i * 4) ::*) printLevel(rest)
  in
  let rec loop pt =
    match (isAllEmpty pt) = 0 with
    | true -> Printf.printf "\ndone\n"
    | false -> Printf.printf "\n"; let newHamt = printLevel pt in loop newHamt
  in
  loop [SomeHAMT hamt] *)


let makeString hamt =
  let count : int ref = ref 0 in
  let getNewIndex () = let i = !count in (count := !count + 1); i in
  let makeNode l =
    let makeVal i v = Printf.sprintf "<f%d>%s" i v in
    let getString oT =
      match oT with
      | Edge _ -> " "
      | Value i -> Printf.sprintf "%d" i
      | Empty -> " "
    in
    let str = List.mapi (fun i v -> makeVal i (getString v)) l in
    String.concat "|" str
  in
  let rec transform hamt =
    match hamt with
    | ArrayNode {arr; shift} ->
      let i = getNewIndex () in
      let l = Array.fold_right (fun hamt rest -> (transform hamt) :: rest) arr [] in
      Edge (i, l)
    | Entry {hash;key;value} -> Value value
    | CollisionNode {ahash; hmes} -> Value (snd(List.hd hmes))
    | Empty -> Empty
  in
  let rec getNodes outputT =
    match outputT with
    | Edge (i, t) -> (Printf.sprintf "%d," i) ^ makeNode(t) ^ "*" ^ (List.fold_right (fun x str -> getNodes(x) ^ str) t "")
    | _ -> ""
  in
  let rec getEdges oT =
    match oT with
    | Edge (i, t) ->
      let l = List.mapi (fun n x -> match x with | Edge (i2,t2) -> Printf.sprintf "%d:f%d,%d:f%d*" i n i2 2 | _ -> "") t in
      List.fold_right (fun x str-> x ^ str) l "" ^ (List.fold_right (fun x y -> getEdges x ^ y) t "")
    | _ -> ""
  in
  let oT = transform hamt in
  let nodes = getNodes oT in
  let edges = getEdges oT in
  nodes^"."^edges

let export ?name:(name="temp") hamt =
  let file = "print.txt" in
  let str = makeString hamt in
  let oc = open_out file in
  Printf.fprintf oc "%s" str;
  close_out oc;
  let code = Sys.command ("Python print.py" ^ " " ^ name) in
  match code with
  | 0 -> ()
  | _ -> Printf.printf "error when printing\n"

let modify hamt i j =
  let hash = Hashtbl.hash i in
  let isin (ArrayNode {arr; shift}) =
    let cur = Array.get arr (getIndex hash shift) in
    match cur with
    | Entry _ -> true
    | _ -> false
  in
  let rec loop hamt =
    match hamt with
    | ArrayNode {arr; shift} ->
      let index = getIndex hash shift in
      if isin hamt then Array.set arr index (Entry{hash=hash; key=i; value=j}) else loop (Array.get arr index)
    | Entry {hash; key; value} -> ()
    | CollisionNode _ -> ()
    | Empty -> ()
  in
  loop hamt
