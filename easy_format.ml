(* $Id$ *)

open Format

type list_param = {
  space_after_open : bool;
  space_after_separator : bool;
  space_before_close : bool
}

type label_param = {
  space_after_label : bool
}

let spaced_list = {
  space_after_open = true;
  space_after_separator = true;
  space_before_close = true
}

let compact_list = {
  space_after_open = false;
  space_after_separator = false;
  space_before_close = false
}

let spaced_label = {
  space_after_label = true
}

let compact_label = {
  space_after_label = false
}


type t =
    Atom of string
  | List of (string * string * string * list_param) * t list
  | Label of (string * label_param) * t


module Pretty =
struct

  let rec fprint_t fmt indent = function
      Atom s -> fprintf fmt "%s" s
    | List (param, l) -> fprint_list fmt indent param l
    | Label (label, x) -> fprint_pair fmt indent label x
      
  (* Printing a list which is not after a label *)
  and fprint_list fmt indent (op, sep, cl, p) = function
      [] -> 
	if p.space_after_open || p.space_before_close then
	  fprintf fmt "%s %s" op cl
	else
	  fprintf fmt "%s%s" op cl
    | x :: tl ->
	pp_open_hvbox fmt indent;
	pp_print_string fmt op;
	if p.space_after_open then
	  pp_print_space fmt ()
	else
	  pp_print_cut fmt ();
	fprint_t fmt indent x;
	List.iter (
	  fun x ->
	    pp_print_string fmt sep;
	    if p.space_after_separator then
	      pp_print_space fmt ()
	    else
	      pp_print_cut fmt ();
	    fprint_t fmt indent x
	) tl;
	if p.space_before_close then
	  pp_print_break fmt 1 (-indent)
	else
	  pp_print_break fmt 0 (-indent);
	pp_print_string fmt cl;
	pp_close_box fmt ()
	  
	  
  (* Printing a label:value pair.
     
     The opening bracket stays on the same line as the key, no matter what,
     and the closing bracket is either on the same line
     or vertically aligned with the beginning of the key. 
  *)
  and fprint_pair fmt indent (label, lp) x =
    match x with
	List ((op, sep, cl, p), l) -> 
	  (match l with
	       [] -> 
		 if lp.space_after_label then
		   fprintf fmt "%s " label
		 else
		   fprintf fmt "%s" label;
		 if p.space_after_open || p.space_before_close then
		   fprintf fmt "%s %s" op cl
		 else
		   fprintf fmt "%s%s" op cl

	     | x :: tl -> 
		 pp_open_hvbox fmt indent;
		 if lp.space_after_label then
		   fprintf fmt "%s " label
		 else
		   fprintf fmt "%s" label;
		 pp_print_string fmt op;
		 if p.space_after_open then
		   pp_print_space fmt ()
		 else
		   pp_print_cut fmt ();

		 fprint_t fmt indent x;
		 List.iter (
		   fun x -> 
		     pp_print_string fmt sep;
		     if p.space_after_separator then
		       pp_print_space fmt ()
		     else
		       pp_print_cut fmt ();
		     fprint_t fmt indent x
		 ) tl;
		 if p.space_before_close then
		   pp_print_break fmt 1 (-indent)
		 else
		   pp_print_break fmt 0 (-indent);
		 pp_print_string fmt cl;
		 pp_close_box fmt ()
	  )
      | _ -> 
	  pp_open_hvbox fmt indent;
	  pp_print_string fmt label;
	  if lp.space_after_label then
	    pp_print_break fmt 1 indent
	  else
	    pp_print_break fmt 0 indent;
	  fprint_t fmt indent x;
	  pp_close_box fmt ()

  let to_formatter ?(indent = 2) fmt x =
    fprint_t fmt indent x;
    pp_print_flush fmt ()
      
  let to_buffer ?indent buf x =
    let fmt = Format.formatter_of_buffer buf in
    to_formatter ?indent fmt x
      
  let to_string ?indent x =
    let buf = Buffer.create 500 in
    to_buffer ?indent buf x;
    Buffer.contents buf
      
  let to_channel ?indent oc x =
    let fmt = formatter_of_out_channel oc in
    to_formatter ?indent fmt x
      
  let to_stdout ?indent x = to_formatter ?indent std_formatter x
  let to_stderr ?indent x = to_formatter ?indent err_formatter x

end




module Compact =
struct
  open Printf
  
  let rec fprint_t buf = function
      Atom s -> Buffer.add_string buf s
    | List (param, l) -> fprint_list buf param l
    | Label (label, x) -> fprint_pair buf label x
	

  and fprint_list buf (op, sep, cl, _) = function
      [] -> bprintf buf "%s%s" op cl
    | x :: tl ->
	Buffer.add_string buf op;
	fprint_t buf x;
	List.iter (
	  fun x ->
	    Buffer.add_string buf sep;
	    fprint_t buf x
	) tl;
	Buffer.add_string buf cl

  and fprint_pair buf (label, _) x =
    Buffer.add_string buf label;
    fprint_t buf x


  let to_buffer buf x = fprint_t buf x

  let to_string x =
    let buf = Buffer.create 500 in
    to_buffer buf x;
    Buffer.contents buf

  let to_formatter fmt x =
    let s = to_string x in
    Format.fprintf fmt "%s" s;
    pp_print_flush fmt ()

  let to_channel oc x =
    let buf = Buffer.create 500 in
    to_buffer buf x;
    Buffer.output_buffer oc buf

  let to_stdout x = to_channel stdout x
  let to_stderr x = to_channel stderr x
end
