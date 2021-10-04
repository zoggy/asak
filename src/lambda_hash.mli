(* This file is part of asak.
 *
 * Copyright (C) 2019 IRIF / OCaml Software Foundation.
 *
 * asak is distributed under the terms of the MIT license. See the
 * included LICENSE file for details. *)

type threshold =
  | Percent of int (** A percentage threshold, a number between 0 and 100. *)
  | Hard of int (** A hard threshold. *)

type config =
  { should_sort : bool;
    (** If we sort all lists of hashes. This is useful to identify more codes,
     but can identify unfactorizable code. *)
    hash_var : bool; (** If we hash names in the AST. *)
    (*hash_const: bool; (** If we hash constants in the AST. *)*)
  }

(** A fingerprint is a weighted Digest.t *)
type fingerprint = int * Digest.t

(** A type synonym for the result of the {! hash_lambda} function *)
type hash = fingerprint * fingerprint list

(** Hash a lambda expression. Usage: [hash_lambda config threshold expr].
    Two lambda expressions "of the same shape" will share the same hash. Particularly,
    constant are ignored.

    @param config A configuration for the function.

    @param threshold Used to decide which sub-AST hash is kept.

    @param expr The expression.

    @return A tuple with the main hash, and a list of hashes of sub-ASTs satisfying the threshold.
*)
val hash_lambda :
  config ->
  threshold ->
  Lambda.lambda -> hash

(** Utilities *)

val map_snd : ('a -> 'b) -> ('c * 'a) list -> ('c * 'b) list

(** Using a threshold, hash a list of lambda expressions from  {! Parse_structure.read_structure }. *)
val hash_all :
  config ->
  threshold->
  ('a * Lambda.lambda) list ->
  ('a * hash) list

(** Escape hashses for printing. *)
val escape_hash :
  hash -> hash
