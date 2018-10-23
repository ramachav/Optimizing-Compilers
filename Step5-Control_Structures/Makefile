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

all_test: test_assembly test_results test_compares test_diffs
test_assembly:
	g++ -o tiny tinyNew.cpp
	./testresults/ramachav_compiler testinputs/step5_test1.micro > testresults/step5_test1.out
	./testresults/ramachav_compiler testinputs/step5_test2.micro > testresults/step5_test2.out
	./testresults/ramachav_compiler testinputs/step5_test3.micro > testresults/step5_test3.out
	./testresults/ramachav_compiler testinputs/step5_test4.micro > testresults/step5_test4.out
	./testresults/ramachav_compiler testinputs/step5_test5.micro > testresults/step5_test5.out
	./testresults/ramachav_compiler testinputs/step5_test6.micro > testresults/step5_test6.out
test_results:
	./tiny testresults/step5_test1.out < testinputs/step5_test1.input > testresults/test1_output.out
	./tiny testresults/step5_test2.out < testinputs/step5_test2.input > testresults/test2_output.out
	./tiny testresults/step5_test3.out < testinputs/step5_test3.input > testresults/test3_output.out
	./tiny testresults/step5_test4.out < testinputs/step5_test4.input > testresults/test4_output.out
	./tiny testresults/step5_test5.out < testinputs/step5_test5.input > testresults/test5_output.out
	./tiny testresults/step5_test6.out < testinputs/step5_test6.input > testresults/test6_output.out
test_compares:
	./tiny testoutputs/step5_test1.out < testinputs/step5_test1.input > testresults/test1_output_compare.out
	./tiny testoutputs/step5_test2.out > testinputs/step5_test2.input > testresults/test2_output_compare.out
	./tiny testoutputs/step5_test3.out < testinputs/step5_test3.input > testresults/test3_output_compare.out
	./tiny testoutputs/step5_test4.out < testinputs/step5_test4.input > testresults/test4_output_compare.out
	./tiny testoutputs/step5_test5.out < testinputs/step5_test5.input > testresults/test5_output_compare.out
	./tiny testoutputs/step5_test6.out < testinputs/step5_test6.input > testresults/test6_output_compare.out
test_diffs:
	diff -b -B testresults/test1_output.out testresults/test1_output_compare.out
	diff -b -B testresults/test2_output.out testresults/test2_output_compare.out
	diff -b -B testresults/test3_output.out testresults/test3_output_compare.out
	diff -b -B testresults/test4_output.out testresults/test4_output_compare.out
	diff -b -B testresults/test5_output.out testresults/test5_output_compare.out
	diff -b -B testresults/test6_output.out testresults/test5_output_compare.out

clean:
	rm -rf autogenerate
	rm -rf testresults
	rm *~
	rm tiny

