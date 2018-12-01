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
	./testresults/ramachav_compiler testinputs/factorial2.micro > testresults/factorial2.out
	./testresults/ramachav_compiler testinputs/fibonacci2.micro > testresults/fibonacci2.out
	./testresults/ramachav_compiler testinputs/fma.micro > testresults/fma.out
	./testresults/ramachav_compiler testinputs/step6_test1.micro > testresults/step6_test1.out
	./testresults/ramachav_compiler testinputs/step6_test2.micro > testresults/step6_test2.out
	./testresults/ramachav_compiler testinputs/step6_test3.micro > testresults/step6_test3.out
	./testresults/ramachav_compiler testinputs/step7_test1.micro > testresults/step7_test1.out
	./testresults/ramachav_compiler testinputs/step7_test2.micro > testresults/step7_test2.out
	./testresults/ramachav_compiler testinputs/step7_test3.micro > testresults/step7_test3.out
	./testresults/ramachav_compiler testinputs/step7_test4.micro > testresults/step7_test4.out
	./testresults/ramachav_compiler testinputs/step7_test5.micro > testresults/step7_test5.out
	./testresults/ramachav_compiler testinputs/step7_test6.micro > testresults/step7_test6.out
	./testresults/ramachav_compiler testinputs/step7_test7.micro > testresults/step7_test7.out
	./testresults/ramachav_compiler testinputs/step7_test8.micro > testresults/step7_test8.out
	./testresults/ramachav_compiler testinputs/step7_test9.micro > testresults/step7_test9.out
	./testresults/ramachav_compiler testinputs/step7_test10.micro > testresults/step7_test10.out
	./testresults/ramachav_compiler testinputs/step7_test11.micro > testresults/step7_test11.out
	./testresults/ramachav_compiler testinputs/step7_test12.micro > testresults/step7_test12.out
	./testresults/ramachav_compiler testinputs/step7_test13.micro > testresults/step7_test13.out
	./testresults/ramachav_compiler testinputs/step7_test14.micro > testresults/step7_test14.out
	./testresults/ramachav_compiler testinputs/step7_test15.micro > testresults/step7_test15.out
	./testresults/ramachav_compiler testinputs/step7_test16.micro > testresults/step7_test16.out
	./testresults/ramachav_compiler testinputs/step7_test17.micro > testresults/step7_test17.out
	./testresults/ramachav_compiler testinputs/step7_test18.micro > testresults/step7_test18.out
	./testresults/ramachav_compiler testinputs/step7_test19.micro > testresults/step7_test19.out
	./testresults/ramachav_compiler testinputs/step7_test20.micro > testresults/step7_test20.out
	./testresults/ramachav_compiler testinputs/step7_test21.micro > testresults/step7_test21.out
	./testresults/ramachav_compiler testinputs/step7_test22.micro > testresults/step7_test22.out
test_results:
	./tiny testresults/factorial2.out < testinputs/factorial2.input > testresults/test61_output.out
	./tiny testresults/fibonacci2.out < testinputs/fibonacci2.input > testresults/test62_output.out
	./tiny testresults/fma.out < testinputs/fma.input > testresults/test63_output.out
	./tiny testresults/step6_test1.out < testinputs/step6_test1.input > testresults/test64_output.out
	./tiny testresults/step6_test2.out < testinputs/step6_test2.input > testresults/test65_output.out
	./tiny testresults/step6_test3.out < testinputs/step6_test3.input > testresults/test66_output.out
	./tiny testresults/step7_test1.out < testinputs/step7_test1.input > testresults/test1_output.out
	./tiny testresults/step7_test2.out < testinputs/step7_test2.input > testresults/test2_output.out
	./tiny testresults/step7_test3.out < testinputs/step7_test3.input > testresults/test3_output.out
	./tiny testresults/step7_test4.out < testinputs/step7_test4.input > testresults/test4_output.out
	./tiny testresults/step7_test5.out < testinputs/step7_test5.input > testresults/test5_output.out
	./tiny testresults/step7_test6.out < testinputs/step7_test6.input > testresults/test6_output.out
	./tiny testresults/step7_test7.out < testinputs/step7_test7.input > testresults/test7_output.out
	./tiny testresults/step7_test8.out < testinputs/step7_test8.input > testresults/test8_output.out
	./tiny testresults/step7_test9.out < testinputs/step7_test9.input > testresults/test9_output.out
	./tiny testresults/step7_test10.out < testinputs/step7_test10.input > testresults/test10_output.out
	./tiny testresults/step7_test11.out < testinputs/step7_test11.input > testresults/test11_output.out
	./tiny testresults/step7_test12.out < testinputs/step7_test12.input > testresults/test12_output.out
	./tiny testresults/step7_test13.out < testinputs/step7_test13.input > testresults/test13_output.out
	./tiny testresults/step7_test14.out < testinputs/step7_test14.input > testresults/test14_output.out
	./tiny testresults/step7_test15.out < testinputs/step7_test15.input > testresults/test15_output.out
	./tiny testresults/step7_test16.out < testinputs/step7_test16.input > testresults/test16_output.out
	./tiny testresults/step7_test17.out < testinputs/step7_test17.input > testresults/test17_output.out
	./tiny testresults/step7_test18.out < testinputs/step7_test18.input > testresults/test18_output.out
	./tiny testresults/step7_test19.out < testinputs/step7_test19.input > testresults/test19_output.out
	./tiny testresults/step7_test20.out < testinputs/step7_test20.input > testresults/test20_output.out
	./tiny testresults/step7_test21.out < testinputs/step7_test21.input > testresults/test21_output.out
	./tiny testresults/step7_test22.out < testinputs/step7_test22.input > testresults/test22_output.out
test_compares:
	./tiny2 testoutputs/factorial2.out < testinputs/factorial2.input > testresults/test61_output_compare.out
	./tiny2 testoutputs/fibonacci2.out < testinputs/fibonacci2.input > testresults/test62_output_compare.out
	./tiny2 testoutputs/fma.out < testinputs/fma.input > testresults/test63_output_compare.out
	./tiny2 testoutputs/step6_test1.out < testinputs/step6_test1.input > testresults/test64_output_compare.out
	./tiny2 testoutputs/step6_test2.out < testinputs/step6_test2.input > testresults/test65_output_compare.out
	./tiny2 testoutputs/step6_test3.out < testinputs/step6_test3.input > testresults/test66_output_compare.out
test_diffs:
	diff -b -B testresults/test61_output.out testresults/test61_output_compare.out
	diff -b -B testresults/test62_output.out testresults/test62_output_compare.out
	diff -b -B testresults/test63_output.out testresults/test63_output_compare.out
	diff -b -B testresults/test64_output.out testresults/test64_output_compare.out
	diff -b -B testresults/test65_output.out testresults/test65_output_compare.out
	diff -b -B testresults/test66_output.out testresults/test66_output_compare.out

clean:
	rm -rf autogenerate
	rm -rf testresults
	rm *~
	rm tiny

