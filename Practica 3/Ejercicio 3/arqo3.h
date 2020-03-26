#ifndef _ARQO_P3_H_
#define _ARQO_P3_H_
#define CLOCKS_PER_SEC_1 ((__clock_t) 1000000)

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#if __x86_64__
	typedef double tipo;
#else
	typedef float tipo;
#endif

tipo ** generateMatrix(int);
tipo ** generateEmptyMatrix(int);
void freeMatrix(tipo **);
double multiplyMatrix(int);
tipo** transposeMatrix(tipo**, int);
double multiplyTransposedMatrix(int);
void printMatrix(tipo**, int);

#endif /* _ARQO_P3_H_ */
