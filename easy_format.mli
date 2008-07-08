(* $Id$ *)

(**
   Easy_format: indentation made easy.
*)

(**
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
  space_after_opening : bool;
  space_after_separator : bool;
  space_before_closing : bool;
  align_closing : bool;
  indent_items : int; (** Extra indentation before list items when 
			  align_closing is true. *)
}

type label_param = {
  space_after_label : bool;
  indent_after_label : int; (** Extra indentation before the item
				that comes after a label. *)
}

(** Predefined style with more space (all fields are true) *)
val spaced_list : list_param
val spaced_label : label_param

(** Predefined style with less space (all fields are false) *)
val compact_list : list_param
val compact_label : label_param


type t =
    Atom of string  (** Plain string. 
		        Should not contain line feeds for optimal rendering. *)

  | List of 
      (
	string    (** Opening delimiter such as: "{"  "["  "("  "begin"  "" *)
	* string  (** Item separator such as: ";"  ","  "" *)
	* string  (** Closing delimiter such as: "}"  "]"  ")"  "end"  "" *)
	* list_param
      ) 
      * t list    (** Items.
		     Without label: array, list or tuple-like items.
		     With label: record fields, object methods,
		     definitions of all kinds.
		  *)

  | Label of (t * label_param) * t   (** Labelled item *)


(** Indentation *)
module Pretty :
sig
  val to_formatter : Format.formatter -> t -> unit
  val to_buffer : Buffer.t -> t -> unit
  val to_string : t -> string
  val to_channel : out_channel -> t -> unit
  val to_stdout : t -> unit
  val to_stderr : t -> unit
end

(** No indentation at all, no newlines other than those in the input data. *)
module Compact :
sig
  val to_buffer : Buffer.t -> t -> unit
  val to_string : t -> string
  val to_channel : out_channel -> t -> unit
  val to_stdout : t -> unit
  val to_stderr : t -> unit
  val to_formatter : Format.formatter -> t -> unit
 end
