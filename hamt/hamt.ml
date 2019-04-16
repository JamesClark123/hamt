(* file: hamt.ml
   author: James Clark

   This file contains a simple implementation of the HAMT data structure

*)
open Hashtbl

module Hamt =
struct
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


  let arrayLen = 16

  let shiftvalue_float = (log (float_of_int arrayLen)) /. (log 2.0)

  let shiftvalue = int_of_float shiftvalue_float

  let rec makeMaskValue i = if i = 0 then 1 else (1 lsl (i-1)) lor (makeMaskValue (i - 1))

  let maskvalue = makeMaskValue shiftvalue

  let getIndex hash shift = (hash asr shift) land maskvalue

  let empty = Empty

  let find_opt (hamt : ('a, 'b) hamt) (key : 'a) =
    let hash = Hashtbl.hash key in

    let rec loop hamt =
      match hamt with
      | ArrayNode {arr; shift} ->
        let index = getIndex hash shift in
        loop (Array.get arr index)
      | Entry {hash; key=k; value} when k = key -> Some {hash;key;value}
      | CollisionNode {ahash; hmes} when ahash = hash ->
        let v = List.find_opt (fun (k, value) -> if k = key then true else false) hmes in
        begin
          match v with
          | Some (key, value) -> Some {hash=ahash; key=key; value=value}
          | None -> None
        end
      | _ -> None
    in
    loop hamt

  let find (hamt : ('a, 'b) hamt) (key : 'a) =
    let o = find_opt hamt key
    in

    match o with
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
        if newList = [] then Empty else CollisionNode {ahash; hmes = newList}
      | _ -> raise Not_found
    in
    let v = try Some (find hamt key) with Not_found -> None in
    match v with
    | Some _ -> loop hamt
    | None -> raise Not_found

  let add (hamt : ('a, 'b) hamt) (key : 'a) (value : 'b) =

    let hsh = Hashtbl.hash key in

    let rec loop hamt shift =
      match hamt with
      | ArrayNode {arr; shift} ->
        let index = getIndex hsh shift in
        let newInsertValue = loop (Array.get arr index) (shift + shiftvalue) in
        let newArr = Array.copy arr in
        let () = Array.set newArr index newInsertValue
        in
        ArrayNode {arr = newArr; shift = shift}

      | Entry {hash=h; key=k; value=v} when h = hsh ->
        if k = key then Entry{hash=h; key=k; value=value} else
          let newHashMapEntry = (key, value)in
          let thisEntry = (k, v) in
          let hMEList = thisEntry :: newHashMapEntry :: []
          in
          CollisionNode {ahash = hsh; hmes = hMEList}

      | CollisionNode {ahash=h; hmes} when h = hsh ->
        let newHMES =(key, value) :: hmes
        in
        CollisionNode {ahash=h; hmes=newHMES}

      (* I choose to seperate out possible cases of Entry and CollisionNode occurences via when statement purely for apperances so as to avoid a nested match statement *)
      (* Note that this also means that any following Entry or CollisionNode occurences are guarenteed to not be a true collision *)

      | Entry {hash=h; key=k; value=v} as thisEntry ->
        (* let newShift = shift + shiftvalue in *)
        let thisIndex = getIndex h shift in
        let newArr = Array.init arrayLen (fun x -> Empty) in
        let () = Array.set newArr thisIndex thisEntry
        in
        loop (ArrayNode {arr=newArr; shift=shift}) shift (* this is a poor way to do this as it results in at least two copies of the new array but I will leave it for now *)

      | CollisionNode {ahash=h; hmes} as thisCollisionNode ->
        (* let newShift = shift + shiftvalue in *)
        let thisIndex = getIndex h shift in
        let newArr = Array.init arrayLen (fun x -> Empty) in
        let () = Array.set newArr thisIndex thisCollisionNode
        in
        loop (ArrayNode {arr=newArr; shift=shift}) shift

      | Empty -> Entry {hash=hsh;key=key;value=value}
    in

    loop hamt 0

  let of_alist (l : ('a * 'b) list) =
    (* let arr = Array.init arrayLen (fun x -> Empty) in *)
    let base = empty (*ArrayNode {arr = arr; shift = 0}*) in
    let rec loop l  hamt =
      match l with
      | [] -> hamt
      | (key, value) :: rest ->
        let anew = add hamt key value in
        loop rest anew
    in
    loop l base
end
