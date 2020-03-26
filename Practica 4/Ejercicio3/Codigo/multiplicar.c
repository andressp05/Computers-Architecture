#include "arqo4.h"
#include "multiplicar.h"

float multiplymatrix_par_loop1(int tam, int num_threads){
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
			omp_set_num_threads(num_threads);
			#pragma omp parallel for reduction(+:sum) private(k)
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

float multiplymatrix_par_loop2(int tam, int num_threads){
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
		omp_set_num_threads(num_threads);
		#pragma omp parallel for reduction(+:sum) private(j, k)
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



int main(int argc, char *argv[]){
	int tam = 0;
	int bucle = 0;
	int num_threads = 0;
	int i = 0;
	float t_serie = 0.0;	
	float t_matrix = 0.0;

	int tam0 = 0;
	int tam1 = 0;

	tam0 = 1000;
	tam1 = 1700;

	/*if(argc != 4){
		printf("<tamanio_mat> <bucle> <num_threads>\n\n");
		return 0;
	}

	tam = atoi(argv[1]);
	bucle = atoi(argv[2]);
	num_threads = atoi(argv[3]);*/
	printf("Tiempos: \n");
	for(i = 0; i < 2; i++){
		if(i == 0){
			tam = tam0;
		}
		else if(i == 1){
			tam = tam1;
		}
		printf("\nTamanio: %d\n", tam);
		for(bucle = 0; bucle <= 3; bucle ++){
			printf("\n");
			for(num_threads = 1; num_threads <= 4; num_threads++){
				//printf("\t");
				if(bucle == 0){
			  		t_serie = multiplymatrix_serie(tam);
			  		printf("%f", t_serie);
			  		//printf("\n");
			  		break; //Solo queremos una iteracion para serie
			  	}
			  	if(bucle == 1){
			  		t_matrix = multiplymatrix_par_loop1(tam, num_threads);
			  		printf("%f", t_matrix);
			  		printf("\t");
			  	}

			  	if(bucle == 2){
			  		t_matrix = multiplymatrix_par_loop2(tam, num_threads);
			  		printf("%f", t_matrix);
			  		printf("\t");
			  	}

			  	if(bucle == 3){
			  		t_matrix = multiplymatrix_par_loop3(tam, num_threads);
			  		printf("%f", t_matrix);
			  		printf("\t");
			  	}  	
			}
		}
		printf("\n");	
	}


	printf("Speedup: \n");
	for(i = 0; i < 2; i++){
		if(i == 0){
			tam = tam0;
		}
		else if(i == 1){
			tam = tam1;
		}
		printf("\nTamanio: %d\n", tam);
		for(bucle = 0; bucle <= 3; bucle ++){
			printf("\n");
			for(num_threads = 1; num_threads <= 4; num_threads++){
				//printf("\t");
				if(bucle == 0){
			  		t_serie = multiplymatrix_serie(tam);
			  		printf("%f", (t_serie/t_serie));
			  		//printf("\n");
			  		break; //Solo queremos una iteracion para serie
			  	}
			  	if(bucle == 1){
			  		t_matrix = multiplymatrix_par_loop1(tam, num_threads);
			  		printf("%f", (t_serie/t_matrix));
			  		printf("\t");
			  	}

			  	if(bucle == 2){
			  		t_matrix = multiplymatrix_par_loop2(tam, num_threads);
			  		printf("%f", (t_serie/t_matrix));
			  		printf("\t");
			  	}

			  	if(bucle == 3){
			  		t_matrix = multiplymatrix_par_loop3(tam, num_threads);
			  		printf("%f", (t_serie/t_matrix));
			  		printf("\t");
			  	}  	
			}
		}
		printf("\n");	
	}

  	return 0;
}
