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
  
  List (
    array_param,
    [
      obj; array; obj;
      Atom "xyz";
    ]
  )


let _ = 
  let x1 = make_data Param.list_false Param.label_false in
  let x2 = make_data Param.list_true Param.label_true in
  let x3 = 
    make_data { Param.list_true with stick_to_label = false } Param.label_true 
  in
  Easy_format.Pretty.to_stdout x1;
  print_newline ();
  Easy_format.Pretty.to_stdout x2;
  print_newline ();
  Easy_format.Pretty.to_stdout x3;
  print_newline ();
  Easy_format.Compact.to_stdout x1;
  print_newline ()
