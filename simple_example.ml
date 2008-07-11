(* $Id$ *)

open Easy_format

let tuple_param = 
  { list with
      space_after_opening = false;
      space_before_closing = false;
      align_closing = false
  }

let operator_param = 
  { list with
      space_after_opening = false;
      space_before_closing = false;
      separators_stick_left = false;
      space_before_separator = true;
      space_after_separator = true;
      align_closing = true
  }

let format_tuple f l =
  List (("(", ",", ")", tuple_param), List.map f l)

let format_int x =
  Atom (string_of_int x)

let format_float x =
  Atom (Printf.sprintf "%.5f" x)

let format_sum ?(wrap = `Wrap_atom_list) l =
  List (("(", "+", ")", { operator_param with wrap_body = wrap }), 
	List.map format_int l)

let format_array ~align_closing ~wrap f a =
  let l = Array.to_list (Array.map f a) in
  List (("[|", ";", "|]", 
	 { list with
	     align_closing = align_closing;
	     wrap_body = wrap }),
	l)

let format_matrix ~align_closing ~wrap m =
  let b1, b2 =
    match align_closing with
	`Cells -> true, false
      | `Rows -> false, true
      | `Both -> false, false
      | `None -> true, true
  in
  format_array ~align_closing:b1 ~wrap
    (format_array ~align_closing:b2 ~wrap format_float) m


let format_record f l0 =
  let l = 
    List.map 
      (fun (s, x) -> Label ((Atom (s ^ ":"), label), f x)) 
      l0 in
  List (("{", ";", "}", list), l)

let begin_style = 
  { label with indent_after_label = 0 },
  ("begin", ";", "end", 
   { list with stick_to_label = false })

let curly_style =
  label,
  ("{", ";", "}", list)

let format_function_definition (body_label, body_param) name param body =
  Label (
    (
      Label (
	(Atom ("function " ^ name), label),
	List (("(", ",", ")", tuple_param), List.map (fun s -> Atom s) param)
      ), 
      body_label
    ),
    List (body_param, List.map (fun s -> Atom s) body)
  )

let print_margin fmt () =
  let margin = Format.pp_get_margin fmt () in
  print_newline ();
  for i = 1 to margin do
    print_char '+'
  done;
  print_newline ()


let with_margin margin f x =
  let fmt = Format.formatter_of_out_channel stdout in
  Format.pp_set_margin fmt margin;
  print_margin fmt ();
  f fmt x;
  Format.pp_print_flush fmt ();
  print_newline ()


let print_tuple fmt l =
  Pretty.to_formatter fmt (format_tuple format_int l)

let print_sum ?wrap fmt l =
  Pretty.to_formatter fmt (format_sum ?wrap l)

let print_matrix ~align_closing ~wrap fmt m =
  Pretty.to_formatter fmt (format_matrix ~align_closing ~wrap m)

let print_function_definition style name param fmt body =
  Pretty.to_formatter fmt (format_function_definition style name param body)

let _ =
  let ints = Array.to_list (Array.init 10 (fun i -> i)) in

  (* A simple tuple that fits on one line *)
  with_margin 80 print_tuple ints;
  with_margin 20 print_tuple ints;

  (* Printed as a sum *)
  with_margin 80 print_sum ints;
  with_margin 20 (print_sum ~wrap:`Yes) ints;
  with_margin 20 (print_sum ~wrap:`No) ints;


  (* Triangular array of arrays showing wrapping of lists of atoms *)
  let m = Array.init 20 (fun i -> Array.init i (fun i -> sqrt (float i))) in
  with_margin 80 (print_matrix ~align_closing: `None ~wrap: `No) m;
  with_margin 80 (print_matrix ~align_closing: `None ~wrap: `Yes) m;
  with_margin 80 (print_matrix ~align_closing: `Cells ~wrap: `Yes) m;
  with_margin 80 (print_matrix ~align_closing: `Rows ~wrap: `Yes) m;
  with_margin 80 (print_matrix ~align_closing: `Both ~wrap: `Yes) m;

  (* A function definition, showed with different right-margin settings
     and either begin-end or { } around the function body. *)
  List.iter (
    fun style ->
      List.iter (
	fun margin ->
	  with_margin margin
	    (print_function_definition
	       style
	       "hello" ["arg1";"arg2";"arg3"]) [
	      "print \"hello\"";
	      "return foo"
	    ]
      ) [ 10; 20; 30; 40; 80 ]
  ) [ curly_style; begin_style ]

