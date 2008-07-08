VERSION = 0.9.0

.PHONY: default all opt test clean
default: all opt
all:
	ocamlc -c easy_format.mli
	ocamlc -c -dtypes easy_format.ml
	touch bytecode
opt:
	ocamlc -c easy_format.mli
	ocamlopt -c easy_format.ml
	touch nativecode
test:
	ocamlc -c easy_format.mli
	ocamlc -c easy_format.ml
	ocamlc -o test_easy_format easy_format.cmo test_easy_format.ml
	./test_easy_format
	ocamlc -o lambda_example easy_format.cmo lambda_example.ml
	./lambda_example
	ocamlc -o simple_example easy_format.cmo simple_example.ml
	./simple_example
clean:
	rm -f *.cm[iox] *.o *.annot test_easy_format lambda_example \
		bytecode nativecode

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
