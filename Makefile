VERSION = 0.9.0

.PHONY: default all opt test doc clean
default: all opt
all:
	ocamlc -c easy_format.mli
	ocamlc -c -dtypes easy_format.ml
	touch bytecode
opt:
	ocamlc -c easy_format.mli
	ocamlopt -c easy_format.ml
	touch nativecode
test: all simple_example.out
	ocamlc -o test_easy_format easy_format.cmo test_easy_format.ml
	./test_easy_format > test_easy_format.out
	ocamlc -o lambda_example easy_format.cmo lambda_example.ml
	./lambda_example > lambda_example.out

simple_example: all simple_example.ml
	ocamlc -o simple_example easy_format.cmo simple_example.ml
simple_example.out: simple_example
	./simple_example > simple_example.out

doc: ocamldoc/index.html simple_example.html
ocamldoc/index.html: easy_format.mli
	ocamldoc -d ocamldoc -html $<
simple_example.html: simple_example.out simple_example.ml
	cat simple_example.ml > easy_format_example.ml
	echo '(* Output: ' >> easy_format_example.ml
	cat simple_example.out >> easy_format_example.ml
	echo '*)' >> easy_format_example.ml
	caml2html easy_format_example.ml -t -o $@
clean:
	rm -f *.cm[iox] *.o *.annot \
		test_easy_format lambda_example simple_example \
		bytecode nativecode *.out ocamldoc/* \
		example.* easy_format_example.html 

COMMON_INSTALL_FILES = META easy_format.cmi easy_format.mli
BC_INSTALL_FILES = easy_format.cmo 
NC_INSTALL_FILES = easy_format.cmx easy_format.o

install:
	echo "version = \"$(VERSION)\"" > META; cat META.tpl >> META
	INSTALL_FILES="$(COMMON_INSTALL_FILES)"; \
		if test -f bytecode; then \
		  INSTALL_FILES="$$INSTALL_FILES $(BC_INSTALL_FILES)"; \
		fi; \
		if test -f nativecode; then \
		  INSTALL_FILES="$$INSTALL_FILES $(NC_INSTALL_FILES)"; \
		fi; \
		ocamlfind install easy-format $$INSTALL_FILES

uninstall:
	ocamlfind remove easy-format
