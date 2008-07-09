(* $Id$ *)

open Format

type list_param = {
  space_after_opening : bool;
  space_after_separator : bool;
  space_before_closing : bool;
  stick_to_label : bool;
  align_closing : bool;
  indent_items : int
}

type label_param = {
  space_after_label : bool;
  indent_after_label : int
}

module Param =
struct
  let spaced_list = {
    space_after_opening = true;
    space_after_separator = true;
    space_before_closing = true;
    stick_to_label = true;
    align_closing = true;
    indent_items = 2
  }

  let compact_list = {
    space_after_opening = false;
    space_after_separator = false;
    space_before_closing = false;
    stick_to_label = false;
    align_closing = false;
    indent_items = 2
  }
    
  let spaced_label = {
    space_after_label = true;
    indent_after_label = 2;
  }
    
  let compact_label = {
    space_after_label = false;
    indent_after_label = 2;
  }
end


type t =
    Atom of string
  | List of (string * string * string * list_param) * t list
  | Label of (t * label_param) * t


module Pretty =
struct
  let extra_box l = 
    if List.for_all (function Atom _ -> true | _ -> false) l then
      ((fun fmt -> pp_open_hovbox fmt 0),
       (fun fmt -> pp_close_box fmt ()))
    else
      ((fun fmt -> ()),
       (fun fmt -> ()))

  let rec fprint_t fmt = function
      Atom s -> fprintf fmt "%s" s
    | List ((_, _, _, p) as param, l) ->
	if p.align_closing then
	  fprint_list fmt param l
	else
	  fprint_list2 fmt param l

    | Label (label, x) -> fprint_pair fmt label x
      
  (* Printing a list which is not after a label *)
  and fprint_list fmt (op, sep, cl, p) = function
      [] -> 
	if p.space_after_opening || p.space_before_closing then
	  fprintf fmt "%s %s" op cl
	else
	  fprintf fmt "%s%s" op cl
    | x :: tl as l ->
	let indent = p.indent_items in
	pp_open_hvbox fmt indent;
	pp_print_string fmt op;
	if p.space_after_opening then
	  pp_print_space fmt ()
	else
	  pp_print_cut fmt ();

	let open_extra, close_extra = extra_box l in
	open_extra fmt;

	fprint_t fmt x;
	List.iter (
	  fun x ->
	    pp_print_string fmt sep;
	    if p.space_after_separator then
	      pp_print_space fmt ()
	    else
	      pp_print_cut fmt ();
	    fprint_t fmt x
	) tl;

	close_extra fmt;


	if p.space_before_closing then
	  pp_print_break fmt 1 (-indent)
	else
	  pp_print_break fmt 0 (-indent);
	pp_print_string fmt cl;
	pp_close_box fmt ()

  and fprint_list2 fmt (op, sep, cl, p) = function
      [] -> 
	if p.space_after_opening || p.space_before_closing then
	  fprintf fmt "%s %s" op cl
	else
	  fprintf fmt "%s%s" op cl
    | x :: tl ->
	pp_print_string fmt op;
	if p.space_after_opening then
	  pp_print_string fmt " ";

	pp_open_hovbox fmt 0;

	fprint_t fmt x;
	List.iter (
	  fun x ->
	    pp_print_string fmt sep;
	    if p.space_after_separator then
	      pp_print_space fmt ()
	    else
	      pp_print_cut fmt ();
	    fprint_t fmt x
	) tl;

	pp_close_box fmt ();

	if p.space_before_closing then
	  pp_print_string fmt " ";
	pp_print_string fmt cl
	  
  (* Printing a label:value pair.
     
     The opening bracket stays on the same line as the key, no matter what,
     and the closing bracket is either on the same line
     or vertically aligned with the beginning of the key. 
  *)
  and fprint_pair fmt (label, lp) x =
    match x with
	List ((op, sep, cl, p), l) when p.stick_to_label && p.align_closing -> 
	  (match l with
	       [] -> 
		 fprint_t fmt label;
		 if lp.space_after_label then
		   fprintf fmt " ";
		 if p.space_after_opening || p.space_before_closing then
		   fprintf fmt "%s %s" op cl
		 else
		   fprintf fmt "%s%s" op cl

	     | x :: tl -> 
		 let indent = p.indent_items in
		 pp_open_hvbox fmt indent;
		 fprint_t fmt label;
		 if lp.space_after_label then
		   fprintf fmt " ";
		 pp_print_string fmt op;
		 if p.space_after_opening then
		   pp_print_space fmt ()
		 else
		   pp_print_cut fmt ();

		 let open_extra, close_extra = extra_box l in
		 open_extra fmt;

		 fprint_t fmt x;
		 List.iter (
		   fun x -> 
		     pp_print_string fmt sep;
		     if p.space_after_separator then
		       pp_print_space fmt ()
		     else
		       pp_print_cut fmt ();
		     fprint_t fmt x
		 ) tl;

		 close_extra fmt;


		 if p.space_before_closing then
		   pp_print_break fmt 1 (-indent)
		 else
		   pp_print_break fmt 0 (-indent);
		 pp_print_string fmt cl;
		 pp_close_box fmt ()
	  )
      | _ -> 
	  let indent = lp.indent_after_label in
	  pp_open_hvbox fmt 0;
	  fprint_t fmt label;
	  if lp.space_after_label then
	    pp_print_break fmt 1 indent
	  else
	    pp_print_break fmt 0 indent;
	  fprint_t fmt x;
	  pp_close_box fmt ()

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
    fprint_t buf label;
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
