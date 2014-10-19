CC = gcc

CFLAGS = -Wall			 	\
	 -O3			 	\
	 -std=c99			\
	 -pedantic-errors		\
	 -g				\
	 -lmysqlclient			\
	 -DDEBUG

PROGRAM = nothing

.PHONY: all

all: $(PROGRAM)

$(PROGRAM): main.c
	$(CC) main.c -o $@ $(CFLAGS)

clean:
	rm -f $(PROGRAM) *.o
