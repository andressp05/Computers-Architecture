LIBS = 
LIB_DIR =  
FLAGS = -g -lgomp -Wall -D_GNU_SOURCE -fopenmp

.PHONY: clean all

all: multiplicar multiplicar_incr clear 

multiplicar: multiplicar.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)
	
multiplicar_incr: multiplicar_incr.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)		

clean:
	rm -f *.o *~ multiplicar multiplicar_incr 
clear:
	rm -f *.o *~
