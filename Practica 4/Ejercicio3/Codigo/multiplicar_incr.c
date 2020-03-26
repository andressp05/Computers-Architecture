#include "arqo4.h"
#include "multiplicar.h"

#define P 6 //29 (mod 8) + 1 = 5 + 1 = 6;
#define BEST_THREADS_NUM 4

float multiplymatrix_serie(int tam){
	int i = 0, j = 0, k = 0;
	tipo **a = NULL;
	tipo **b = NULL;
	tipo **c = NULL;

	float tiempo;

	double sum = 0.0;	
	struct timeval fin,ini;

	a = generateMatrix(tam);
	b = generateMatrix(tam);
	c = generateEmptyMatrix(tam);

	gettimeofday(&ini,NULL);

	for(i = 0; i < tam; i++){ /*nos movemos primero en las columnas de la matriz a y por cada una de estas recorremos todas las columnas de la matriz b*/
		for(j = 0; j < tam; j++){
			for(k = 0; k < tam; k++){
				sum += a[i][k]*b[k][j];
				c[i][j] = sum;
			}	
		}
	}
	gettimeofday(&fin,NULL);

	tiempo = (((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);

	//printf("%f", tiempo);


	freeMatrix(a);
	freeMatrix(b);
	freeMatrix(c);

	//printf("Resultado: %f\n", sum);

	return tiempo;
}

float multiplymatrix_par_loop3(int tam, int num_threads){
	int i = 0, j = 0, k = 0;
	tipo **a = NULL;
	tipo **b = NULL;
	tipo **c = NULL;

	float tiempo;

	double sum = 0.0;	
	struct timeval fin,ini;

	a = generateMatrix(tam);
	b = generateMatrix(tam);
	c = generateEmptyMatrix(tam);

	gettimeofday(&ini,NULL);


	omp_set_num_threads(num_threads);
	#pragma omp parallel for reduction(+:sum) private(i, j, k)
	for(i = 0; i < tam; i++){ /*nos movemos primero en las columnas de la matriz a y por cada una de estas recorremos todas las columnas de la matriz b*/
		for(j = 0; j < tam; j++){
			for(k = 0; k < tam; k++){
				sum += a[i][k]*b[k][j];
				c[i][j] = sum;
			}	
		}
	}
	gettimeofday(&fin,NULL);

	tiempo = (((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);

	//printf("%f", tiempo);

	freeMatrix(a);
	freeMatrix(b);
	freeMatrix(c);
	
	//printf("Resultado: %f\n", sum);

	return tiempo;
}

int main(int argc, char *argv[]){
	int arg = 0;
	int tam1 = 512 + P;
	int tam2 = 1024 + 512 + P;
	int incr = 64;
	int tam = 0;
	float tiempo = 0.0;

	if(argc != 2){
		printf("<serie(0)/paralelo(1)>: \n");
		return 0;
	}

	arg = atoi(argv[1]);

	if(arg != 0 && arg != 1){
		printf("Introduzca 0 para la version serie y 1 para la paralelo en el bucle externo: \n");
		return 0;
	}

	if(!arg){
		for(tam = tam1; tam <= tam2; tam += incr){
			tiempo = multiplymatrix_serie(tam);
			printf("%d %f\n",tam, tiempo);
		}	
	}

	if(arg){
		for(tam = tam1; tam <= tam2; tam += incr){
			tiempo = multiplymatrix_par_loop3(tam, BEST_THREADS_NUM);
			printf("%d %f\n",tam, tiempo);
		}	
	}

	return 0;
}
