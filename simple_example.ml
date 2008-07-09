(* $Id$ *)

open Easy_format

let tuple_param = 
  { Param.list_false with space_after_separator = true }

let format_tuple f l =
  List (("(", ",", ")", tuple_param), List.map f l)

let format_float x =
  Atom (string_of_float x)

let format_array ~align_closing f a =
  let l = Array.to_list (Array.map f a) in
  List (("[|", ";", "|]", 
	 { Param.list_true with align_closing = align_closing }),
	l)

let format_matrix ~wrap m =
  match wrap with
      `Cells ->
	format_array ~align_closing:true 
	  (format_array ~align_closing:false format_float) m
    | `Rows ->
	format_array ~align_closing:false 
	  (format_array ~align_closing:true format_float) m
    | `Both ->
	format_array ~align_closing:false 
	  (format_array ~align_closing:false format_float) m
    | `None ->
	format_array ~align_closing:true 
	  (format_array ~align_closing:true format_float) m


let format_record f l0 =
  let l = 
    List.map 
      (fun (s, x) -> Label ((Atom (s ^ ":"), Param.label_true), f x)) 
      l0 in
  List (("{", ";", "}", Param.list_true), l)

let begin_style = 
  { Param.label_true with indent_after_label = 0 },
  ("begin", ";", "end", 
   { Param.list_true with stick_to_label = false })

let curly_style =
  Param.label_true,
  ("{", ";", "}", Param.list_true)

let format_function_definition (body_label, body_param) name param body =
  Label (
    (
      Label (
	(Atom ("function " ^ name), Param.label_true),
	List (("(", ",", ")", tuple_param), List.map (fun s -> Atom s) param)
      ), 
      body_label
    ),
    List (body_param, List.map (fun s -> Atom s) body)
  )

let print_margin () =
  let margin = Format.get_margin () in
  print_newline ();
  for i = 1 to margin do
    print_char '+'
  done;
  print_newline ()

let print_tuple l =
  print_margin ();
  Pretty.to_stdout (format_tuple format_float l);
  print_newline ()

let print_matrix ~wrap m =
  print_margin ();
  Pretty.to_stdout (format_matrix ~wrap m);
  print_newline ()

let print_function_definition ~margin style name param body =
  let margin0 = Format.get_margin () in
  Format.set_margin margin;
  print_margin ();
  Pretty.to_stdout (format_function_definition style name param body);
  Format.set_margin margin0;
  print_newline ()

let _ =
  (* A simple tuple that fits on one line *)
  print_tuple [ 1.; 2.; 3.; 4. ];
  print_newline ();

  (* Triangular array of arrays showing wrapping of lists of atoms *)
  let m = Array.init 30 (fun i -> Array.init i float) in
  print_matrix ~wrap: `None m;
  print_matrix ~wrap: `Cells m;
  print_matrix ~wrap: `Rows m;
  print_matrix ~wrap: `Both m;

  (* A function definition, showed with different right-margin settings
     and either begin-end or { } around the function body. *)
  List.iter (
    fun style ->
      List.iter (
	fun margin ->
	  print_function_definition
	    ~margin style
	    "hello" ["arg1";"arg2";"arg3"] [
	      "print \"hello\"";
	      "return foo"
	    ];
	  print_newline ()
      ) [ 10; 20; 30; 40; 80 ]
  ) [ curly_style; begin_style ]
