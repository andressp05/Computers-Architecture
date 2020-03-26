#include "arqo3.h"

int main(int argc, char** argv){
	
	int tam = 0;
	double tiempo = 0.0;
	
	if (argc != 2){
		perror("Debe introducir lo siguiente para ejecutar el ejercicio 3:\n ./arqo3 <tamanio_de_la_matriz> \n");
	}

	tam = atoi(argv[1]);

	tiempo = multiplyTransposedMatrix(tam);
	printf("%f\n", tiempo);

	return 0;
}
