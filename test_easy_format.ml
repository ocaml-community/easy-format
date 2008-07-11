(* $Id$ *)

open Easy_format

let make_data list_param label_param =
  let obj_param = ("{", ",", "}", list_param) in
  let array_param = ("[", ",", "]", list_param) in
  let obj =
    List (
      obj_param,
      [
	Label (
	  (Atom "x:", label_param), 
	  Atom "y"
	);
	Label (
	  (Atom "y:", label_param), 
	  List (obj_param, [Label ((Atom "z:", label_param), Atom "aaa")])
	);
	Label (
	(Atom "a:", label_param), 
	  List (
	    array_param,
	    [ 
	      Atom "abc"; 
	      Atom "\"long long long......................................\
                    ....................................................\"";
	    ]
	  )
	);
	Label (
	  (Atom "\"a long label ..................\
                   .............................\":",
	   label_param),
	  List (
	    array_param,
	    [
	      Atom "123";
	      Atom "456";
	      Atom "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	    ]
	  )
	)
      ]
    )
  in

  let array = 
    List (array_param, [ Atom "a"; Atom "b"; Atom "c"; Atom "d" ]) 
  in
  
  Label (
    (Atom "abc:", label_param), 
    List (
      array_param,
      [
	obj; array; obj;
	Atom "xyz";
      ]
    )
  )


let _ = 
  let x1 = make_data list label in
  let x2 =
    make_data
      { list with 
	  space_after_opening = false;
	  space_after_separator = false;
	  space_before_closing = false;
	  stick_to_label = false;
	  align_closing = false }
      { label with 
	  space_after_label = true } in
  let x3 =
    make_data
      { list with 
	  space_after_opening = false;
	  space_before_separator = true;
	  space_after_separator = true;
	  separators_stick_left = false;
	  space_before_closing = false;
	  stick_to_label = true;
	  align_closing = true }
      { label with 
	  space_after_label = true } in
  let x4 = 
    make_data { list with stick_to_label = false } label
  in

  Easy_format.Pretty.to_stdout x1;
  print_newline ();

  Easy_format.Pretty.to_stdout x2;
  print_newline ();

  Easy_format.Pretty.to_stdout x3;
  print_newline ();

  Easy_format.Pretty.to_stdout x4;
  print_newline ();

  Easy_format.Compact.to_stdout x1;
  print_newline ()

