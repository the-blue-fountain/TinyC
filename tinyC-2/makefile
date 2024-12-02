#Usage:
# run : run the executable on test file
# auto : run the executable on test file and automatically clean
# zip : zip the files for submission 

NAME = tinyC2_22CS30043_22CS30011

all:
	flex $(NAME).l
	bison -d $(NAME).y -o y.tab.c
	gcc lex.yy.c $(NAME).c

run: all
	-./a.out < $(NAME)_test.c > $(NAME)_output.txt

auto: run
	make clean

clean:
	-rm lex.yy.c y.tab.c y.tab.h a.out

zip: auto
	zip $(NAME).zip $(NAME).l $(NAME).y $(NAME).c $(NAME)_test.c $(NAME)_output.txt makefile