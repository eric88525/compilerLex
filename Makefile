all:  lex c

CC = gcc

lex: lex.l
	flex lex.l
c: lex.yy.c
	$(CC) lex.yy.c -ll

