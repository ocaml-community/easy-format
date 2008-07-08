(* $Id$ *)

(* 
   Easy_format: indentation made easy.
*)

(*
  This module offers classic C-style indentation.
  It provides a simplified interface over
  the Format module of the standard library.

  Input data must be first modelled as a tree using 3 kinds of nodes:
  - atoms
  - lists
  - labelled nodes

  Atoms represent any text that is guaranteed to be printed as-is.
  Lists can model any sequence of items such as arrays of data
  or lists of definitions that are labelled with something 
  like "int main", "let x =" or "x:".
*)


type list_param = {
  space_after_open : bool;
  space_after_separator : bool;
  space_before_close : bool
}

type label_param = {
  space_after_label : bool
}

(* Style with more space *)
val spaced_list : list_param
val spaced_label : label_param

(* Style with less space *)
val compact_list : list_param
val compact_label : label_param


type t =
    Atom of string   (* Plain string. 
			Should not contain line feeds for optimal rendering. *)

  | List of 
      (
	string    (* Opening delimiter such as: "{"  "["  "("  "begin"  "" *)
	* string  (* Item separator such as: ";"  ","  "" *)
	* string  (* Closing delimiter such as: "}"  "]"  ")"  "end"  "" *)
	* list_param
      ) 
      * t list    (* Items.
		     Without label: array, list or tuple-like items.
		     With label: record fields, object methods,
		     function definitions, variable definition.
		  *)

  | Label of (string * label_param) * t   (* Labelled item *)


(* Indentation *)
module Pretty :
sig
  val to_formatter : ?indent:int -> Format.formatter -> t -> unit
  val to_buffer : ?indent:int -> Buffer.t -> t -> unit
  val to_string : ?indent:int -> t -> string
  val to_channel : ?indent:int -> out_channel -> t -> unit
  val to_stdout : ?indent:int -> t -> unit
  val to_stderr : ?indent:int -> t -> unit
end

(* No indentation at all, no newlines other than those in the input data. *)
module Compact :
sig
  val to_buffer : Buffer.t -> t -> unit
  val to_string : t -> string
  val to_channel : out_channel -> t -> unit
  val to_stdout : t -> unit
  val to_stderr : t -> unit
  val to_formatter : Format.formatter -> t -> unit
 end
