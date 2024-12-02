NAME = tinyC3_22CS30043_22CS30011
CC = g++ -std=c++11

all: a.out
	
	./a.out < testFiles/$(NAME)_test1.c > outputFiles/$(NAME)_quads1.out
	@echo "Test File 1 Successfully Translated !\n"
	./a.out < testFiles/$(NAME)_test2.c > outputFiles/$(NAME)_quads2.out
	@echo "Test File 2 Successfully Translated !\n"
	./a.out < testFiles/$(NAME)_test3.c > outputFiles/$(NAME)_quads3.out
	@echo "Test File 3 Successfully Translated !\n"
	./a.out < testFiles/$(NAME)_test4.c > outputFiles/$(NAME)_quads4.out
	@echo "Test File 4 Successfully Translated !\n"
	./a.out < testFiles/$(NAME)_test5.c > outputFiles/$(NAME)_quads5.out
	@echo "Test File 5 Successfully Translated !\n"

	@echo "\nALL TEST FILES SUCCESSFULLY TRANSLATED !!\n"

a.out: lex.yy.o y.tab.o $(NAME)_translator.o
	$(CC) lex.yy.o y.tab.o $(NAME)_translator.o 

$(NAME)_translator.o: $(NAME)_translator.cxx $(NAME)_translator.h
	$(CC) -c $(NAME)_translator.h
	$(CC) -c $(NAME)_translator.cxx

lex.yy.o: lex.yy.c
	$(CC) -c lex.yy.c

y.tab.o: y.tab.c
	$(CC) -c y.tab.c

lex.yy.c: $(NAME).l y.tab.h $(NAME)_translator.h
	flex $(NAME).l

y.tab.c: $(NAME).y
	bison -dtv $(NAME).y -W -o y.tab.c

y.tab.h: $(NAME).y
	bison -dtv $(NAME).y -W -o y.tab.h

clean:
	-rm lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o $(NAME)_translator.o y.output a.out $(NAME)_translator.h.gch

zip: clean
	zip -r $(NAME).zip . -x $(NAME).zip