everything: team compiler
team:
	echo "Team: ramachav"
	echo "Vaibhav Ramachandran"
	echo "Github Username: ramachav"
compiler: parser

parser:
	bison src/parser.yy -d -o parser.cpp
	mkdir autogenerate
	mv parser.cpp autogenerate
	mv parser.hpp autogenerate
	flex src/scanner.ll
	mv lex.yy.c autogenerate
	mkdir testresults
	g++ autogenerate/lex.yy.c autogenerate/parser.cpp src/fileparser.cpp -lfl -o testresults/ramachav_compiler

test_parser:
	./testresults/ramachav_compiler testinputs/test1.micro > testresults/test1.out
	./testresults/ramachav_compiler testinputs/test2.micro > testresults/test2.out
	./testresults/ramachav_compiler testinputs/test3.micro > testresults/test3.out
	./testresults/ramachav_compiler testinputs/test4.micro > testresults/test4.out
	./testresults/ramachav_compiler testinputs/test5.micro > testresults/test5.out
	./testresults/ramachav_compiler testinputs/test6.micro > testresults/test6.out
	./testresults/ramachav_compiler testinputs/test7.micro > testresults/test7.out
	./testresults/ramachav_compiler testinputs/test8.micro > testresults/test8.out
	./testresults/ramachav_compiler testinputs/test9.micro > testresults/test9.out
	./testresults/ramachav_compiler testinputs/test10.micro > testresults/test10.out
	./testresults/ramachav_compiler testinputs/test11.micro > testresults/test11.out
	./testresults/ramachav_compiler testinputs/test12.micro > testresults/test12.out
	./testresults/ramachav_compiler testinputs/test13.micro > testresults/test13.out
	./testresults/ramachav_compiler testinputs/test14.micro > testresults/test14.out
	./testresults/ramachav_compiler testinputs/test15.micro > testresults/test15.out
	./testresults/ramachav_compiler testinputs/test16.micro > testresults/test16.out
	./testresults/ramachav_compiler testinputs/test17.micro > testresults/test17.out
	./testresults/ramachav_compiler testinputs/test18.micro > testresults/test18.out
	./testresults/ramachav_compiler testinputs/test19.micro > testresults/test19.out
	./testresults/ramachav_compiler testinputs/test20.micro > testresults/test20.out
	./testresults/ramachav_compiler testinputs/test21.micro > testresults/test21.out
	diff -b -B testoutputs/test1.out testresults/test1.out
	diff -b -B testoutputs/test2.out testresults/test2.out
	diff -b -B testoutputs/test3.out testresults/test3.out
	diff -b -B testoutputs/test4.out testresults/test4.out
	diff -b -B testoutputs/test5.out testresults/test5.out
	diff -b -B testoutputs/test6.out testresults/test6.out
	diff -b -B testoutputs/test7.out testresults/test7.out
	diff -b -B testoutputs/test8.out testresults/test8.out
	diff -b -B testoutputs/test9.out testresults/test9.out
	diff -b -B testoutputs/test10.out testresults/test10.out
	diff -b -B testoutputs/test11.out testresults/test11.out
	diff -b -B testoutputs/test12.out testresults/test12.out
	diff -b -B testoutputs/test13.out testresults/test13.out
	diff -b -B testoutputs/test14.out testresults/test14.out
	diff -b -B testoutputs/test15.out testresults/test15.out
	diff -b -B testoutputs/test16.out testresults/test16.out
	diff -b -B testoutputs/test17.out testresults/test17.out
	diff -b -B testoutputs/test18.out testresults/test18.out
	diff -b -B testoutputs/test19.out testresults/test19.out
	diff -b -B testoutputs/test20.out testresults/test20.out
	diff -b -B testoutputs/test21.out testresults/test21.out

clean:
	rm -rf autogenerate
	rm -rf testresults
	rm *~

