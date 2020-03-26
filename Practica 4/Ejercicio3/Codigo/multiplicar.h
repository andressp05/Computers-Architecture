#ifndef _MULTIPLICAR_H_
#define _MULTIPLICAR_H_

#include "arqo4.h"
#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <time.h>
#include <omp.h>

float multiplymatrix_par_loop1(int tam, int num_threads);
float multiplymatrix_par_loop2(int tam, int num_threads);
float multiplymatrix_par_loop3(int tam, int num_threads);
float multiplymatrix_serie(int tam);

#endif /* _MULTIPLICAR_H_ */
