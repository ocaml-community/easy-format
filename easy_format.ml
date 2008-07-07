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

  let rec fprint_t fmt = function
      Atom s -> fprintf fmt "%s" s
    | List (param, l) -> fprint_list fmt param l
    | Label (label, x) -> fprint_pair fmt label x
      
  (* Printing a list which is not after a label *)
  and fprint_list fmt (op, sep, cl, p) = function
      [] -> fprintf fmt "%s%s" op cl
    | x :: tl ->
	if p.space_after_open then
	  fprintf fmt "@[<hv 2>%s@ " op
	else
	  fprintf fmt "@[<hv 2>%s@," op;
	fprint_t fmt x;
	List.iter (fun x ->
		     if p.space_after_separator then
		       fprintf fmt "%s@ %a" sep fprint_t x
		     else
		       fprintf fmt "%s@,%a" sep fprint_t x)
	  tl;
	if p.space_before_close then
	  fprintf fmt "@;<1 -2>%s@]" cl
	else
	  fprintf fmt "@;<0 -2>%s@]" cl
	  
	  
  (* Printing a label:value pair.
     
     The opening bracket stays on the same line as the key, no matter what,
     and the closing bracket is either on the same line
     or vertically aligned with the beginning of the key. 
  *)
  and fprint_pair fmt (label, lp) x =
    match x with
	List ((op, sep, cl, p), l) -> 
	  (match l with
	       [] -> 
		 if lp.space_after_label then
		   fprintf fmt "%s %s%s" label op cl
		 else
		   fprintf fmt "%s%s%s" label op cl
	     | x :: tl -> 
		 if lp.space_after_label then
		   fprintf fmt "@[<hv 2>%s " label
		 else
		   fprintf fmt "@[<hv 2>%s" label;
		 if p.space_after_open then
		   fprintf fmt "%s@ " op
		 else
		   fprintf fmt "%s@," op;

		 fprint_t fmt x;
		 List.iter (
		   fun x -> 
		     if p.space_after_separator then
		       fprintf fmt "%s@ %a" sep fprint_t x
		     else
		       fprintf fmt "%s@,%a" sep fprint_t x
		 ) tl;
		 if p.space_before_close then
		   fprintf fmt "@;<1 -2>%s@]" cl
		 else
		   fprintf fmt "@;<0 -2>%s@]" cl)
      | _ -> 
	  (* An atom, perhaps a long string that would go to the next line *)
	  if lp.space_after_label then
	    fprintf fmt "@[%s@;<1 2>%a@]" label fprint_t x
	  else
	    fprintf fmt "@[%s@;<0 2>%a@]" label fprint_t x

  let to_formatter fmt x =
    fprint_t fmt x;
    pp_print_flush fmt ()
      
  let to_buffer buf x =
    let fmt = Format.formatter_of_buffer buf in
    to_formatter fmt x
      
  let to_string x =
    let buf = Buffer.create 500 in
    to_buffer buf x;
    Buffer.contents buf
      
  let to_channel oc x =
    let fmt = formatter_of_out_channel oc in
    to_formatter fmt x
      
  let to_stdout x = to_formatter std_formatter x
  let to_stderr x = to_formatter err_formatter x

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
