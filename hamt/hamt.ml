(* file: hamt.ml
   author: James Clark

   This file contains a simple implementation of the HAMT data structure

*)
open Hashtbl
open Printf


type ('a, 'b) hashMapEntry = { hash : int
                             ; key : 'a
                             ; value : 'b
                             }

and ('a, 'b) collisionNode = { ahash : int
                             ; hmes : ('a * 'b) list
                             }

and ('a, 'b) arrayNode = { arr : (('a, 'b) hamt) array
                         ; shift : int
                         }

and ('a, 'b) hamt = ArrayNode of ('a, 'b) arrayNode
                  | Entry of ('a, 'b) hashMapEntry
                  | CollisionNode of ('a, 'b) collisionNode
                  | Empty


type ('a, 'b) printT = SomeHAMT of ('a, 'b) hamt
                     | NoHAMT of int


let arrayLen = 4

let shiftvalue_float = (log (float_of_int arrayLen)) /. (log 2.0)

let shiftvalue = int_of_float shiftvalue_float

let maskvalue = (shiftvalue -1) lor shiftvalue

let getIndex hash shift = (hash asr shift) land maskvalue

let find (hamt : ('a, 'b) hamt) (key : 'a) =

  let hash = Hashtbl.hash key in

  let rec loop hamt =
    match hamt with
    | ArrayNode {arr; shift} ->
      let index = getIndex hash shift in
      loop (Array.get arr index)
    | Entry {hash=h; key; value} when hash = h -> Some {hash;key;value}
    | CollisionNode {ahash; hmes} when ahash = hash ->
      let v = List.find_opt (fun (k, value) -> if k = key then true else false) hmes in
      begin
        match v with
        | Some (key, value) -> Some {hash=ahash; key=key; value=value}
        | None -> None
      end
    | _ -> None
  in

  match loop hamt with
  | Some {hash;key;value} -> value
  | None -> raise Not_found

let remove (hamt : ('a, 'b) hamt) (key : 'a) =
  let hash = Hashtbl.hash key in
  let rec loop hamt =
    match hamt with
    | ArrayNode {arr; shift} ->
      let index = getIndex hash shift in
      let newArr = Array.copy arr in
      let newVal = loop (Array.get arr index) in
      let () = Array.set newArr index newVal
      in
      ArrayNode {arr = newArr; shift}
    | Entry {hash=h; key; value} when h = hash ->
      Empty
    | CollisionNode {ahash; hmes} when ahash = hash ->
      let newList = List.remove_assoc key hmes in
      CollisionNode {ahash; hmes = newList}
    | _ -> raise Not_found
  in
  let v = try Some (find hamt key) with Not_found -> None in
  match v with
  | Some _ -> loop hamt
  | None -> raise Not_found

let add (hamt : ('a, 'b) hamt) (key : 'a) (value : 'b) =

  let hash = Hashtbl.hash key in

  let rec loop hamt shift =
    match hamt with
    | ArrayNode {arr; shift} ->
      let index = getIndex hash shift in
      let newInsertValue = loop (Array.get arr index) (shift + shiftvalue) in
      let newArr = Array.copy arr in
      let () = Array.set newArr index newInsertValue
      in
      ArrayNode {arr = newArr; shift = shift}

    | Entry {hash=h; key=k; value=v} when h = hash ->
      let newHashMapEntry = (key, value)in
      let thisEntry = (k, v) in
      let hMEList = thisEntry :: newHashMapEntry :: []
      in
      CollisionNode {ahash = hash; hmes = hMEList}

    | CollisionNode {ahash=h; hmes} when h = hash ->
      let newHMES =(key, value) :: hmes
      in
      CollisionNode {ahash=h; hmes=newHMES}

    (* I choose to seperate out possible cases of Entry and CollisionNode occurences via when statement purely for apperances so as to avoid a nested match statement *)
    (* Note that this also means that any following Entry or CollisionNode occurences are guarenteed to not be a true collision *)

    | Entry {hash=h; key=k; value=v} as thisEntry ->
      let newShift = shift + shiftvalue in
      let thisIndex = getIndex h newShift in
      let newArr = Array.init arrayLen (fun x -> Empty) in
      let () = Array.set newArr thisIndex thisEntry
      in
      loop (ArrayNode {arr=newArr; shift=newShift}) newShift (* this is a poor way to do this as it results in at least two copies of the new array but I will leave it for now *)

    | CollisionNode {ahash=h; hmes} as thisCollisionNode ->
      let newShift = shift + shiftvalue in
      let thisIndex = getIndex h newShift in
      let newArr = Array.init arrayLen (fun x -> Empty) in
      let () = Array.set newArr thisIndex thisCollisionNode
      in
      loop (ArrayNode {arr=newArr; shift=newShift}) newShift

    | Empty -> Entry {hash=hash;key=key;value=value}
  in

  loop hamt 0

let init (l : ('a * 'b) list) =
  let arr = Array.init arrayLen (fun x -> Empty) in
  let base = ArrayNode {arr = arr; shift = 0} in
  let rec loop l  hamt =
    match l with
    | [] -> hamt
    | (key, value) :: rest ->
      let anew = add hamt key value in
      loop rest anew
  in
  loop l base

let initq i =
  let arr = Array.init arrayLen (fun x -> Empty) in
  let base = ArrayNode {arr = arr; shift = 0} in
  let rec loop i hamt =
    match i with
    | 0 -> hamt
    | _ -> loop (i-1) (add hamt i i)
  in
  loop i base

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
    Printf.printf "|"
    (* match i with
       | 0 -> Printf.printf "|"
       | i -> Printf.printf "|"; printBlanks (i-1) *)
  in
  let rec printLevel hamt_list =
    match hamt_list with
    | [] -> []
    | SomeHAMT ArrayNode {arr; shift} :: rest -> Array.iter (fun x -> p x) arr
                                               ; Printf.printf "  "
                                               ; Array.fold_right (fun x l -> SomeHAMT x :: l) arr (printLevel rest)
    | SomeHAMT Entry {hash; key; value} :: rest -> (*p (List.hd hamt_list)
                                                     ;*) NoHAMT 4 :: (printLevel rest)
    | SomeHAMT CollisionNode {ahash; hmes} :: rest -> List.iter (fun (key, value) -> Printf.printf "%d " value) hmes
                                                    ; NoHAMT 4 :: (printLevel rest)
    | SomeHAMT Empty :: rest -> printBlanks 4; NoHAMT 4 :: printLevel(rest)
    | NoHAMT i :: rest -> printBlanks i; NoHAMT (i * 4) :: printLevel(rest)
  in
  let rec loop pt =
    let newHamt = printLevel pt in
    match (isAllEmpty newHamt) = 0 with
    | true -> Printf.printf "\ndone\n"
    | false -> Printf.printf "\n"; loop newHamt
  in
  loop [SomeHAMT hamt]

let go () =
  let testHamt = init [(1,1); (2,2); (3,3); (4,4); (5,5); (6,6); (7,7); (8,8); (9,9); (10,10); (11,11); (12,12); (13,13); (14,14)] in
  let aVal = find testHamt 13 in
  let newHamt = remove testHamt 13 in
  let testHamt2 = initq 50 in
  print testHamt;
  Printf.printf "%d\n" aVal;
  print newHamt;
  print testHamt2

let s = go ()
