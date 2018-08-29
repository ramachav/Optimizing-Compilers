everything: team compiler
team:
	echo "Team: ramachav"
	echo "Vaibhav Ramachandran"
	echo "Github Username: ramachav"
compiler: flex_setup scanner

scanner:
	mkdir testresults
	gcc autogenerate/lex.yy.c -lfl -o testresults/ramachav_compiler 
flex_setup:
	flex src/scanner.l
	mkdir autogenerate
	mv lex.yy.c autogenerate

test_scanner:
	./testresults/ramachav_compiler testinputs/fibonacci.micro > testresults/fibonacci.out
	./testresults/ramachav_compiler testinputs/loop.micro > testresults/loop.out
	./testresults/ramachav_compiler testinputs/nested.micro > testresults/nested.out
	./testresults/ramachav_compiler testinputs/sqrt.micro > testresults/sqrt.out
	diff -b -B testoutputs/fibonacci.out testresults/fibonacci.out
	diff -b -B testoutputs/loop.out testresults/loop.out
	diff -b -B testoutputs/nested.out testresults/nested.out
	diff -b -B testoutputs/sqrt.out testresults/sqrt.out

clean:
	rm -rf autogenerate
	rm -rf testresults
	rm *~
