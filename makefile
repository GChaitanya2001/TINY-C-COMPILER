SPLFLAG = "-no-pie"

asm_generate: COMPILER
	@echo "\n ================= TEST CASES =======================\n"
	./COMPILER 1 > ass6_18CS30018_quads1.out
	@echo "++++++++Test Case 1 ran successfully++++++\n"
	./COMPILER 2 > ass6_18CS30018_quads2.out
	@echo "++++++++Test Case 2 ran successfully++++++\n"
	./COMPILER 3 > ass6_18CS30018_quads3.out
	@echo "++++++++Test Case 3 ran successfully++++++\n"
	./COMPILER 4 > ass6_18CS30018_quads4.out
	@echo "++++++++Test Case 4 ran successfully++++++\n"
	./COMPILER 5 > ass6_18CS30018_quads5.out
	@echo "++++++++Test Case 5 ran successfully++++++\n"
	./COMPILER 6 > ass6_18CS30018_quads6.out
	@echo "++++++++Test Case 6 ran successfully++++++\n"
	@echo "=> The following commands are illustrated to run the executables of first test file"
	@echo " > make clean1"
	@echo " > make test1"
	@echo " > ./test1"
	@echo "=> Do anologously for other executables of test files by replacing 1 by 2 | 3 | 4 | 5 | 6 |\n"

COMPILER: lex.yy.o y.tab.o ass6_18CS30018_translator.o ass6_18CS30018_target_translator.o
	g++ lex.yy.o y.tab.o ass6_18CS30018_translator.o \
	ass6_18CS30018_target_translator.o -lfl -o COMPILER

ass6_18CS30018_target_translator.o: ass6_18CS30018_target_translator.cxx
	g++ -c ass6_18CS30018_target_translator.cxx

ass6_18CS30018_translator.o: ass6_18CS30018_translator.cxx ass6_18CS30018_translator.h
	g++ -c ass6_18CS30018_translator.h
	g++ -c ass6_18CS30018_translator.cxx

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

y.tab.o: y.tab.c
	g++ -c y.tab.c

lex.yy.c: ass6_18CS30018.l y.tab.h ass6_18CS30018_translator.h
	flex ass6_18CS30018.l

y.tab.c: ass6_18CS30018.y
	yacc -dtv ass6_18CS30018.y -Wyacc

y.tab.h: ass6_18CS30018.y
	yacc -dtv ass6_18CS30018.y -Wyacc
	
clean:
	rm lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o ass6_18CS30018_translator.o test1 test2 test3 test4 test5 y.output COMPILER ass6_18CS30018_target_translator.o libass6_18CS30018.a ass6_18CS30018_1.o ass6_18CS30018_lib.o ass6_18CS30018_2.o ass6_18CS30018_3.o ass6_18CS30018_4.o ass6_18CS30018_5.o ass6_18CS30018_1.s ass6_18CS30018_2.s ass6_18CS30018_3.s ass6_18CS30018_4.s ass6_18CS30018_5.s ass6_18CS30018_6.s test1 ass6_18CS30018_1.o ass6_18CS30018_lib.o test2 ass6_18CS30018_2.o ass6_18CS30018_lib.o test3 ass6_18CS30018_3.o ass6_18CS30018_lib.o test4 ass6_18CS30018_4.o ass6_18CS30018_lib.o test5 ass6_18CS30018_5.o ass6_18CS30018_lib.o test6 ass6_18CS30018_6.o ass6_18CS30018_lib.o

clean1:
	rm test1 ass6_18CS30018_1.o libass6_18CS30018.a ass6_18CS30018_lib.o
	
clean2:
	rm test2 ass6_18CS30018_2.o libass6_18CS30018.a ass6_18CS30018_lib.o
	
clean3:
	rm test3 ass6_18CS30018_3.o libass6_18CS30018.a ass6_18CS30018_lib.o
	
clean4:
	rm test4 ass6_18CS30018_4.o libass6_18CS30018.a ass6_18CS30018_lib.o

clean5:
	rm test5 ass6_18CS30018_5.o libass6_18CS30018.a ass6_18CS30018_lib.o
		
clean6:
	rm test6 ass6_18CS30018_6.o libass6_18CS30018.a ass6_18CS30018_lib.o
			
test1: ass6_18CS30018_1.o libass6_18CS30018.a
	gcc $(SPLFLAG) ass6_18CS30018_1.o -o test1 -L. -lass6_18CS30018
ass6_18CS30018_1.o: myl.h
	gcc -Wall -c ass6_18CS30018_1.s

test2: ass6_18CS30018_2.o libass6_18CS30018.a
	gcc $(SPLFLAG) ass6_18CS30018_2.o -o test2 -L. -lass6_18CS30018
ass6_18CS30018_2.o: myl.h
	gcc -Wall -c ass6_18CS30018_2.s

test3: ass6_18CS30018_3.o libass6_18CS30018.a
	gcc $(SPLFLAG) ass6_18CS30018_3.o -o test3 -L. -lass6_18CS30018
ass6_18CS30018_3.o: myl.h
	gcc -Wall -c ass6_18CS30018_3.s

test4: ass6_18CS30018_4.o libass6_18CS30018.a
	gcc $(SPLFLAG) ass6_18CS30018_4.o -o test4 -L. -lass6_18CS30018
ass6_18CS30018_4.o: myl.h
	gcc -Wall -c ass6_18CS30018_4.s

test5: ass6_18CS30018_5.o libass6_18CS30018.a
	gcc $(SPLFLAG) ass6_18CS30018_5.o -o test5 -L. -lass6_18CS30018
ass6_18CS30018_5.o: myl.h
	gcc -Wall -c ass6_18CS30018_5.s
	
test6: ass6_18CS30018_6.o libass6_18CS30018.a
	gcc $(SPLFLAG) ass6_18CS30018_6.o -o test6 -L. -lass6_18CS30018
ass6_18CS30018_6.o: myl.h
	gcc -Wall -c ass6_18CS30018_6.s
	
libass6_18CS30018.a: ass6_18CS30018_lib.o
	ar -rcs libass6_18CS30018.a ass6_18CS30018_lib.o

ass6_18CS30018_lib.o: ass6_18CS30018_lib.c myl.h
	gcc -Wall -c ass6_18CS30018_lib.c
