// ----------- Arqo P4-----------------------
// pescalar_serie
//

#include <stdio.h>
#include <stdlib.h>
#include "arqo4.h"

int main(int argc, char *argv[])
{
	float *A=NULL, *B=NULL;
	long long k=0;
	struct timeval fin,ini;
	float sum=0;
	unsigned long long tam_vector;

	if(argc != 2){
		printf("<tam_vector>\n");
		return 0;	
	}

	tam_vector = atoi(argv[1]);
	
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
	for(k=0;k<tam_vector;k++)
	{
		sum = sum + A[k]*B[k];
	}
	/* Fin del computo */
	gettimeofday(&fin,NULL);

	//printf("%f\n",sum);//Resultado
	printf("%f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);//Tiempo
	freeVector(A);
	freeVector(B);

	return 0;
}
