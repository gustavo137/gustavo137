/*
 * Metodo de integracion numerica para calcular el valor de pi 
 * basado en la integral de la funcion f(x) = 1 / (1 + x^2)  en el intervalo [0, 1].
 * Donde la integral es igual a pi/4.
 * Podemos aproximar la integral usando la suma de Riemann con el metodo del punto medio.
 * 1. Dividimos el intervalo [0, 1] en N subintervalos iguales.
 * 2. Calculamos el ancho de cada subintervalo h = 1/N.
 * 3. Para cada subintervalo, calculamos el punto medio x_i = (i + 0.5) * h.
 * 4. Evaluamos la funcion en el punto medio f(x_i) = 1 / (1 + x_i^2).
 * 5. Sumamos todas las evaluaciones y multiplicamos por el ancho h para obtener la aproximacion de la integral.
 * 6. Finalmente, multiplicamos el resultado por 4 para obtener el valor aproximado de pi.
 *  Con N=1e8, obtenemos una aproximacion bastante precisa de pi.
 *
 *
*/
#include <stdio.h>
#include <math.h>
#include <omp.h>
#include <mpi.h>

/* Funcion f(x) = 1 / (1 + x^2) */
double f(double x) {
    return 1.0 / (1.0 + x * x);
}

int main(int argc, char *argv[]){
    // Inicializacion de MPI
    MPI_Init(&argc, &argv);
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    
    // tiempo inicial
    double start_time = MPI_Wtime();

    long long int N = 100000000;    // número de intervalos
    double h = 1.0 / (double) N;    // ancho del intervalo
    double sum = 0.0;
    double x;
    #pragma omp parallel for reduction(+:sum) private(x) schedule(static)
    for (long long int i = 0; i < N; i++) {
        x = (i + 0.5) * h;          // punto medio de cada subintervalo
        /* sum += 1.0 / (1.0 + x * x); */
        sum += f(x);
    }
    // tiempo final
    double end_time = MPI_Wtime();
    if (rank == 0) {
        printf("Numero de ranks: %d\n", size);
        printf("Pi es aproximadamente: %.15f\n", 4.0 * h * sum, "versus", M_PI);
        printf("Error absoluto: %.15f\n", fabs(M_PI - (4.0 * h * sum)));
        printf("Tiempo de ejecucion: %f segundos\n", end_time - start_time);
    }
    return 0;
}

