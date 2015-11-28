VERSION = 1.1.0
export VERSION

NATDYNLINK := $(shell if [ -f `ocamlfind ocamlc -where`/dynlink.cmxa ]; \
                      then echo YES; else echo NO; fi)

ifeq "${NATDYNLINK}" "YES"
CMXS=easy_format.cmxs
endif

.PHONY: default all opt test doc soft-clean clean
default: all opt
all:
	ocamlfind ocamlc -c easy_format.mli
	ocamlfind ocamlc -c -dtypes easy_format.ml
	touch bytecode

opt: easy_format.cmx $(CMXS)
	touch nativecode

easy_format.cmx:
	ocamlfind ocamlc -c easy_format.mli
	ocamlfind ocamlopt -c -dtypes easy_format.ml

easy_format.cmxs: easy_format.cmx
	ocamlfind ocamlopt -I . -shared -linkall \
	  -o easy_format.cmxs easy_format.cmx

test: all simple_example.out
	ocamlfind ocamlc -o test_easy_format -dtypes \
	  easy_format.cmo test_easy_format.ml
	./test_easy_format > test_easy_format.out
	ocamlfind ocamlc -o lambda_example -dtypes \
	  easy_format.cmo lambda_example.ml
	./lambda_example > lambda_example.out

simple_example: all simple_example.ml
	ocamlfind ocamlc -o simple_example -dtypes \
	  easy_format.cmo simple_example.ml
simple_example.out: simple_example
	./simple_example > simple_example.out

doc: ocamldoc/index.html easy_format_example.html
ocamldoc/index.html: easy_format.mli
	mkdir -p ocamldoc
	ocamlfind ocamldoc -d ocamldoc -html $<
easy_format_example.html: simple_example.out simple_example.ml
	cat simple_example.ml > easy_format_example.ml
	echo '(* Output: ' >> easy_format_example.ml
	cat simple_example.out >> easy_format_example.ml
	echo '*)' >> easy_format_example.ml
	ocamlfind ocamlc -c -dtypes easy_format_example.ml
	caml2html easy_format_example.ml -t -o easy_format_example.html

soft-clean:
	rm -f *.cm[iox] *.cmxs *.o *.annot \
		test_easy_format lambda_example simple_example \
		bytecode nativecode

clean: soft-clean
	rm -f *.out ocamldoc/* \
		easy_format_example.*
	cd examples; $(MAKE) clean


COMMON_INSTALL_FILES = META easy_format.cmi easy_format.mli
BC_INSTALL_FILES = easy_format.cmo
NC_INSTALL_FILES = easy_format.cmx easy_format.o $(CMXS)

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
