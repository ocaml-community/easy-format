(* $Id$ *)

open Easy_format

let format_float x =
  Atom (string_of_float x)

let format_array f a =
  let l = Array.to_list (Array.map f a) in
  List (("[|", ";", "|]", spaced_list), l)

let format_matrix m =
  format_array (format_array format_float) m

let tuple_param = { 
  space_after_open = false;
  space_after_separator = true;
  space_before_close = false
}

let format_tuple f l =
  List (("(", ",", ")", tuple_param), List.map f l)


let print_matrix m =
  Pretty.to_stdout (format_matrix m)

let print_tuple l =
  Pretty.to_stdout (format_tuple format_float l)


let _ =
  print_matrix (Array.init 30 (fun i -> Array.init i float));
  print_newline ();
  print_tuple [ 1.; 2.; 3.; 4. ];
  print_newline ()

