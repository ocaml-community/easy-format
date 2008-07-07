.PHONY: all opt test clean
all:
	ocamlc -c easy_format.mli
	ocamlc -c -dtypes easy_format.ml
opt:
	ocamlc -c easy_format.mli
	ocamlopt -c easy_format.ml
test:
	ocamlc -c easy_format.mli
	ocamlc -c easy_format.ml
	ocamlc -o test_easy_format easy_format.cmo test_easy_format.ml
	./test_easy_format
	ocamlc -o lambda_example easy_format.cmo lambda_example.ml
	./lambda_example
clean:
	rm -f *.cm[iox] *.o *.annot test_easy_format lambda_example
