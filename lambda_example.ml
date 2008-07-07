type lambda =
    Lambda of string * lambda
  | Var of string
  | Apply of lambda * lambda



(* \n f x. n (\g h. h (g f)) (\u. x) (\u. u) *)
(* \n. \f. \x. n (\g. \h. h (g f)) (\u. x) (\u. u) *)

let sample_data =
  Lambda (
    "n",
    (Lambda (
       "f",
       (Lambda (
	  "x",
	  Apply (
	    Apply ( 
	      Apply (
		Var "n", 
		(Lambda (
		   "g", 
		   (Lambda (
		      "h", 
		      Apply (Var "h", Apply (Var "g", Var "f"))
		    )
		   )
		 )
		)
	      ),
	      (Lambda ("u", Var "x"))
	    ),
	    (Lambda ("u", Var "u"))
	  )
	)
       )
     )
    )
  )
    

(****************************************************************************)
(* Example from http://caml.inria.fr/resources/doc/guides/format.html
   using Format directly. *)

open Format

let ident = pp_print_string;;
let kwd = pp_print_string;;

let rec pr_exp0 ppf = function
  | Var s ->  ident ppf s
  | lam -> fprintf ppf "@[<1>(%a)@]" pr_lambda lam

and pr_app ppf = function
  | e ->  fprintf ppf "@[<2>%a@]" pr_other_applications e

and pr_other_applications ppf f =
  match f with
  | Apply (f, arg) -> fprintf ppf "%a@ %a" pr_app f pr_exp0 arg
  | f -> pr_exp0 ppf f

and pr_lambda ppf = function
 | Lambda (s, lam) ->
     fprintf ppf "@[<1>%a%a%a@ %a@]" kwd "\\" ident s kwd "." pr_lambda lam
 | e -> pr_app ppf e;;

let print_lambda x =
  pr_lambda std_formatter x; 
  pp_print_flush std_formatter ()


let _ = 
  print_endline 
    "Example from \
     http://caml.inria.fr/resources/doc/guides/format.html#example";
  print_lambda sample_data;
  print_newline ()



(***************************************************************************)
(* Same example, using Easy_format *)

open Printf
open Easy_format

let app_param = 
  ("", "", "",
   { space_after_open = false;
     space_after_separator = true;
     space_before_close = false })

let rec exp0_node = function
    Var s -> Atom s
  | lam -> List (("(", "", ")", compact_list), [lambda_node lam])

and app_node = function
    Apply (f, arg) -> List (app_param, [app_node f; exp0_node arg])
  | f -> exp0_node f
      
and lambda_node = function
    Lambda (s, lam) ->
      Label ((sprintf "\\%s." s, spaced_label), lambda_node lam)
  | e -> app_node e


let _ =
  print_endline "Same, using Easy_format";
  Pretty.to_stdout (lambda_node sample_data);
  print_newline ()

