#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>

#include "arqo3.h"

#define P 6	 

tipo **generateMatrix(int size);
void freeMatrix(tipo **matrix);

tipo **generateMatrix(int size)
{
	tipo *array=NULL;
	tipo **matrix=NULL;
	int i=0,j=0;

	matrix=(tipo **)malloc(sizeof(tipo *)*size);
	array=(tipo *)malloc(sizeof(tipo)*size*size);
	if( !array || !matrix)
	{
		printf("Error when allocating matrix of size %d.\n",size);
		if( array )
			free(array);
		if( matrix )
			free(matrix);
		return NULL;
	}

	srand(0);
	for(i=0;i<size;i++)
	{
		matrix[i] = &array[i*size];
		for(j=0;j<size;j++)
		{
			matrix[i][j] = (1.0*rand()) / (RAND_MAX/10);
		}
	}

	return matrix;
}

tipo **generateEmptyMatrix(int size)
{
	tipo *array=NULL;
	tipo **matrix=NULL;
	int i=0;

	matrix=(tipo **)malloc(sizeof(tipo *)*size);
	array=(tipo *)malloc(sizeof(tipo)*size*size);
	if( !array || !matrix)
	{
		printf("Error when allocating matrix of size %d.\n",size);
		if( array )
			free(array);
		if( matrix )
			free(matrix);
		return NULL;
	}

	for(i=0;i<size;i++)
	{
		matrix[i] = &array[i*size];
	}

	return matrix;
}


void freeMatrix(tipo **matrix)
{
	if( matrix && matrix[0] )
		free(matrix[0]);
	if( matrix )
		free(matrix);
	return;
}

double multiplyMatrix(int n){
	int i = 1;
	int j = 1;
	int k = 1;
	double sum = 0.0;	
	clock_t t_ini, t_fin;
  	double secs;

	tipo **a = NULL;
	tipo **b = NULL;
	tipo **c = NULL;

	a = generateMatrix(n);
	b = generateMatrix(n);

	c = generateEmptyMatrix(n);

	/*A borrar luego*/
	/*printf("Imprimiendo matriz a: \n");
	//printMatrix(a, n);
	//printf("Imprimiendo matriz b: \n");
	//printMatrix(b, n);*/
	t_ini = clock();

	for(i = 0; i < n; i++){ /*nos movemos primero en las columnas de la matriz a y por cada una de estas recorremos todas las columnas de la matriz b*/
		for(j = 0; j < n; j++){
			for(k = 0; k < n; k++){
				sum += a[i][k]*b[k][j];
				c[i][j] = sum;
			}	
		}
	}

	t_fin = clock();

	freeMatrix(a);
	freeMatrix(b);

	secs = (double)(t_fin - t_ini) / CLOCKS_PER_SEC_1;
  	/*printf("La matriz normal tardo %.16g milisegundos\n", secs * 1000.0);*/

	return secs;
}

tipo **transposeMatrix(tipo **matrix, int n){
	int i = 1;
	int j = 1;

	tipo **aux = NULL;

	aux = generateEmptyMatrix(n);

	for(i = 0; i < n; i++){
		for(j = 0; j < n; j++){
			aux[i][j] = matrix[j][i]; /*Transpongo los elementos uno a uno*/
		}
	}

	return aux;
}

double multiplyTransposedMatrix(int n){
	int i = 1;
	int j = 1;
	int k = 1;
	double sum = 0.0;
	clock_t t_ini, t_fin;
 	double secs;
	

	tipo **a = NULL;
	tipo **b = NULL;
	tipo **c = NULL;
	/*tipo **bt = NULL;*/

	a = generateMatrix(n);
	b = generateMatrix(n);
	c = generateEmptyMatrix(n);

	/*A borrar luego*/
	/*printf("Imprimiendo matriz a: \n");
	printMatrix(a, n);*/

	t_ini = clock();	

	b = transposeMatrix(b, n);/*Transpongo matriz b; podriamos almacenarlo en bt pero no es necesario y para reducir tiempos reducimos variables*/

	//printf("Imprimiendo matriz b ya traspuesta: \n");
	//printMatrix(b, n);

	

	/*Multiplicamos la matriz teniendo en cuenta la nueva organizacion de esta, ya que esta traspuesta*/
	for(i = 0; i < n; i++){ /*nos movemos primero en las columnas de la matriz a y por cada una de estas recorremos todas las columnas de la matriz b*/
		for(j = 0; j < n; j++){
			for(k = 0; k < n; k++){
				sum += a[i][k]*b[j][k];
				c[i][j] = sum;
			}	
		}
	}
	t_fin = clock();
	/*Hay que liberar todas ya que solo nos piden tiempos pero de momento lo dejo asi para ver si esta bien*/
	freeMatrix(a);
	freeMatrix(b);

	secs = (double)(t_fin - t_ini) / CLOCKS_PER_SEC_1;
  	/*printf("La matriz traspuesta tardo %.16g segundos\n", secs * 1000.0);*/

	return secs;
}

void printMatrix(tipo** matrix, int tam){
	int i = 0;
	int j = 0;

	if(!matrix || tam <= 0){
		return;
	}

	for(i = 0; i < tam; i++){
		for(j = 0; j < tam; j++){
			fprintf(stdout, "%f ", matrix[i][j]);
		}
		printf("\n");
	}
	printf("\n");

	return;
}

