(* $Id$ *)

(**
   Easy_format: indentation made easy.
*)

(**
  This module provides a functional, simplified layer over
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

type wrap =
    [ `Wrap_atom_list
    | `Yes
    | `No ]
(** List wrapping conditions:
    - [`Wrap_atom_list]: wrap if the list contains only atoms
    - [`Yes]: always wrap
    - [`No]: never wrap
*)

(** List-formatting parameters. 
    Always derive a new set of parameters from an existing record. 
    See {!Easy_format.list}.
*)
type list_param = {
  space_after_opening : bool; (** Whether there must be some whitespace
				  after the opening string. 
				  Default: true *)
  space_after_separator : bool; (** Whether there must be some whitespace
				    after the item separators.
				    Default: true *)
  space_before_separator : bool; (** Whether there must be some whitespace
				     before the item separators.
				     Default: false *)
  separators_stick_left : bool; (** Whether the separators must
				    stick to the item on the left.
				    Default: true *)
  space_before_closing : bool; (** Whether there must be some whitespace
				   before the closing string.
				   Default: true *)
  stick_to_label : bool; (** Whether the opening string should be fused
			     with the preceding label.
			     Default: true *)
  align_closing : bool; (** Whether the beginning of the 
			    closing string must be aligned
			    with the beginning of the opening string
			    (stick_to_label = false) or
			    with the beginning of the label if any
			    (stick_to_label = true).
			    Default: true *)
  wrap : wrap; (** Defines under which conditions the list body
		   may be wrapped, i.e. allow several lines
		   and several list items per line.
		   Default: [`Wrap_atom_list] *)
  indent_body : int; (** Extra indentation of the list body.
			 Default: 2 *)
}

val list : list_param 
  (** Default list-formatting parameters, using the default values
      described in the type definition above.

      In order to make code compatible with future versions of the library,
      the record inheritance syntax should be used, e.g.
      [ { list with align_closing = false } ].
      If new record fields are added, the program would still compile
      and work as before.
  *)

(** Label-formatting parameters. 
    Always derive a new set of parameters from an existing record. 
    See {!Easy_format.label}.
*)
type label_param = {
  space_after_label : bool; (** Whether there must be some whitespace
				after the label. *)
  indent_after_label : int; (** Extra indentation before the item
				that comes after a label.
				A typical value is 2.
			    *)
}

val label : label_param
  (** Default label-formatting parameters, using the default values
      described in the type definition above.
      
      In order to make code compatible with future versions of the library,
      the record inheritance syntax should be used, e.g.
      [ { label with indent_after_label = 0 } ].
      If new record fields are added, the program would still compile
      and work as before.
 *)



type t =
    Atom of string  (** Plain string normally without line feeds. *)

  | List of 
      (
	string    (* opening *)
	* string  (* separator *)
	* string  (* closing *)
	* list_param
      ) 
      * t list   
	(** [List ((opening, separator, closing, param), elements)] *)

  | Label of (t * label_param) * t 
      (** [Label ((label, param), node)]: labelled node. *)
(** The type of the tree to be pretty-printed. Each node contains
    its own formatting parameters.
    
    Detail of a list node 
    [List ((opening, separator, closing, param), elements)]:
    
    - [opening]: opening string such as ["\{"] ["\["] ["("] ["begin"] [""].
    - [separator]: element separator such as [";"] [","] [""].
    - [closing]: closing string such as ["\}"] ["\]"] [")"] ["end"] [""].
    - [elements]: elements that constitute the list body.

*)

(** The regular pretty-printing functions *)
module Pretty :
sig
  val to_formatter : Format.formatter -> t -> unit
  val to_buffer : Buffer.t -> t -> unit
  val to_string : t -> string
  val to_channel : out_channel -> t -> unit
  val to_stdout : t -> unit
  val to_stderr : t -> unit
end

(** No spacing at all, no newlines other than those in the input data. *)
module Compact :
sig
  val to_buffer : Buffer.t -> t -> unit
  val to_string : t -> string
  val to_channel : out_channel -> t -> unit
  val to_stdout : t -> unit
  val to_stderr : t -> unit
  val to_formatter : Format.formatter -> t -> unit
 end


(**/**)

(** Deprecated. Predefined sets of parameters *)
module Param :
sig
  val list_true : list_param
    (** Deprecated. All boolean fields set to true. indent_body = 2. *)

  val label_true : label_param
    (** Deprecated. All boolean fields set to true. indent_after_label = 2. *)

  val list_false : list_param
    (** Deprecated. All boolean fields set to false. indent_body = 2. *)
    
  val label_false : label_param
    (** Deprecated. All boolean fields set to false. indent_after_label = 2. *)
end

