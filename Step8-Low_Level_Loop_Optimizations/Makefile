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
	g++ -o tiny tiny4regs.cpp
	g++ -o tiny2 tinyNew.cpp
	./testresults/ramachav_compiler testinputs/step8_testcase1.micro > testresults/step8_testcase1.out
	./testresults/ramachav_compiler testinputs/step8_testcase2.micro > testresults/step8_testcase2.out
	./testresults/ramachav_compiler testinputs/step8_testcase3.micro > testresults/step8_testcase3.out
	./testresults/ramachav_compiler testinputs/step8_testcase4.micro > testresults/step8_testcase4.out
	./testresults/ramachav_compiler testinputs/step7_test22.micro > testresults/step7_test22.out
test_results:
	./tiny testresults/step8_testcase1.out > testresults/test1_output.out
	./tiny testresults/step8_testcase2.out > testresults/test2_output.out
	./tiny testresults/step8_testcase3.out > testresults/test3_output.out
	./tiny testresults/step8_testcase4.out > testresults/test4_output.out
	./tiny testresults/step7_test22.out < testinputs/step7_test22.input > testresults/test22_output.out
test_compares:
	./tiny2 testoutputs/step8_testcase1.out > testresults/test1_output_compare.out
	./tiny2 testoutputs/step8_testcase2.out > testresults/test2_output_compare.out
	./tiny2 testoutputs/step8_testcase3.out > testresults/test3_output_compare.out
	./tiny2 testoutputs/step7_test22.out < testinputs/step7_test22.input > testresults/test22_output_compare.out
test_diffs:
	diff -b -B testresults/test1_output.out testresults/test1_output_compare.out
	diff -b -B testresults/test2_output.out testresults/test2_output_compare.out
	diff -b -B testresults/test3_output.out testresults/test3_output_compare.out
	diff -b -B testresults/test22_output.out testresults/test22_output_compare.out

clean:
	rm -rf autogenerate
	rm -rf testresults
	rm *~
	rm tiny tiny2

