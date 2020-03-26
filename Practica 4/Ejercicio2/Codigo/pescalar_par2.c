// ----------- Arqo P4-----------------------
// pescalar_par2
//
#include <stdio.h>
#include <stdlib.h>
#include "arqo4.h"

int main(int argc, char *argv[])
{

	if(argc != 3){
		printf("<num_hilos> <tam_vector>\n");
		return 0;	
	}

	float *A=NULL, *B=NULL;
	long long k=0;
	struct timeval fin,ini;
	float sum=0;
	int threads = 0;
	unsigned long long tam_vector;

	threads = atoi(argv[1]);
	tam_vector = atoi(argv[2]);

	if(threads == 0){
		printf("Introduzca un numero de hilos entre 1 y 4");
		return 0;
	}
	
	A = generateVector(tam_vector);
	B = generateVector(tam_vector);
	if ( !A || !B )
	{
		printf("Error when allocationg matrix\n");
		freeVector(A);
		freeVector(B);
		return -1;
	}
	
	gettimeofday(&ini,NULL);
	/* Bloque de computo */
	sum = 0;

	omp_set_num_threads(threads);

	#pragma omp parallel for reduction(+:sum)
	for(k=0;k<tam_vector;k++)
	{
		sum = sum + A[k]*B[k];
	}
	/* Fin del computo */
	gettimeofday(&fin,NULL);

	printf("%f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	freeVector(A);
	freeVector(B);

	return 0;
}
