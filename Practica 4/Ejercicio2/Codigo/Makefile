LIBS = 
LIB_DIR =  
FLAGS = -g -lgomp -Wall -D_GNU_SOURCE -fopenmp

.PHONY: clean all

all:pescalar_serie pescalar_par2 clear 

pescalar_serie: pescalar_serie.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pescalar_par2: pescalar_par2.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)
	
clean:
	rm -f *.o *~ pescalar_serie pescalar_par2 pescalar_serie.dat pescalar_1.dat pescalar_2.dat pescalar_3.dat pescalar_4.dat
clear:
	rm -f *.o *~
