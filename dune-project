(lang dune 1.10)
(name easy-format)

(generate_opam_files true)
(license "BSD-3-Clause")
(maintainers "martin@mjambon.com")
(authors "Martin Jambon")
(implicit_transitive_deps false)

(package
 (name easy-format)
 (depends
  (dune (>= 1.10))
  (ocaml (>= "4.02.3"))))
