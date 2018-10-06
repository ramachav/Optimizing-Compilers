everything: team compiler
team:
	echo "Team: ramachav"
	echo "Vaibhav Ramachandran"
	echo "Github Username: ramachav"
compiler: assembly

assembly:
	bison -d src/parser.yy
	mkdir autogenerate
	mv parser.tab.cc autogenerate
	mv parser.tab.hh autogenerate
	flex src/scanner.ll
	mv lex.yy.c autogenerate
	mkdir testresults
	g++ autogenerate/lex.yy.c autogenerate/parser.tab.cc src/asm_maker.cpp -lfl -g -o testresults/ramachav_compiler

test_assembly:
	g++ -o tiny tinyNew.cpp
	./testresults/ramachav_compiler testinputs/test_combination.micro > testresults/test_combination.out
	./testresults/ramachav_compiler testinputs/test_complex.micro > testresults/test_complex.out
	./testresults/ramachav_compiler testinputs/test_expr.micro > testresults/test_expr.out
	./testresults/ramachav_compiler testinputs/test_mult.micro > testresults/test_mult.out
	./tiny testresults/test_combination.out > testresults/combination_output.out
	./tiny testresults/test_complex.out > testresults/complex_output.out
	./tiny testresults/test_expr.out > testresults/expr_output.out
	./tiny testresults/test_mult.out > testresults/mult_output.out
	./tiny testoutputs/test_combination.out > testresults/combination_output_compare.out
	./tiny testoutputs/test_complex.out > testresults/complex_output_compare.out
	./tiny testoutputs/test_expr.out > testresults/expr_output_compare.out
	./tiny testoutputs/test_mult.out > testresults/mult_output_compare.out
	diff -b -B testresults/combination_output.out testresults/combination_output_compare.out
	diff -b -B testresults/complex_output.out testresults/complex_output_compare.out
	diff -b -B testresults/expr_output.out testresults/expr_output_compare.out
	diff -b -B testresults/mult_output.out testresults/mult_output_compare.out

clean:
	rm -rf autogenerate
	rm -rf testresults
	rm *~
	rm tiny

