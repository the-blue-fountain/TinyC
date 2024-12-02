CC = gcc
CFLAGS = 


NAME = ass3_22CS30043_22CS30011
LEXER = $(NAME).l
MED = lex.yy.c
MAIN = $(NAME).c
EXECUTABLE = lexer.out
TEST = $(NAME)_test.c

COMPILE = $(CC) $(CFLAGS) -o $(EXECUTABLE) $(MAIN)

$(EXECUTABLE): $(MED)
	$(COMPILE)

$(MED):
	flex $(LEXER)

clean:
	-rm $(MED)
	-rm $(EXECUTABLE)

zip: clean
	-rm $(NAME).tar
	zip $(NAME).tar $(LEXER) $(MAIN) $(TEST) Makefile

test: $(EXECUTABLE) $(TEST)
	./$(EXECUTABLE) < $(TEST)