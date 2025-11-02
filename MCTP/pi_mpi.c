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
 * Compile: mpicc pi_mpi.c -o pi_mpi.x  
 * Run: mpirun --oversubscribe -np 3 pi_mpi.x 
*/
#include <stdio.h>
#include <math.h>
#ifdef _OPENMP
#include <omp.h>
#endif
#include <mpi.h>
/* Funcion f(x) = 1 / (1 + x^2) */
double f(double x) {
    return 1.0 / (1.0 + x * x);
}
int main(int argc, char *argv[]){
    int npes, size;    // numero de procesos
    int me=0;          // proceso master ==0
    long long int N = 100000000;    // número de intervalos
    double h = 1.0 / (double) N;    // ancho del intervalo
    double local_sum = 0.0, global_sum=0.0;
    // Inicializacion de MPI
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &npes);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    // ---------------------------------------------
    // Definir el rango de integracion:
    long long int N_loc = N / size;// N local
    long long int rest  = N % size;//sobrantes
    // marca desde dónde empieza cada proceso según
    // cuántos elementos se asignaron antes.
    long long int offset;
    if (me < rest) {
        N_loc = N_loc + 1;
        offset = npes * N_loc;
    } else {
        offset = npes * N_loc + rest;
    }
    long long int start = offset;
    long long int end   = start + N_loc;
    // ---------------------------------------------
    // ---------------------------------------------
    // Define el rango de integración local simplificado
    /* long long int start = (N / size) * rank; */
    /* long long int end   = (rank == size - 1) ? N : (N / size) * (rank + 1); */ 
    // ---------------------------------------------
    // tiempo inicial
    double start_time = MPI_Wtime();
#ifdef _OPENMP 
   if(npes==me) printf("OpenMP habilitado (%d hilos)\n", omp_get_max_threads());
#else
   if(npes==me) printf("OpenMP no habilitado\n");
#endif
    #pragma omp parallel for reduction(+:local_sum) schedule(static)
    for (long long int i = start; i < end; i++) {
       double x = (i + 0.5) * h;          // punto medio de cada subintervalo
        /* sum += 1.0 / (1.0 + x * x); */
       local_sum += f(x);
    }
    //Reduce las sumas locales en el proceso raiz
    MPI_Reduce(&local_sum,&global_sum,1,MPI_DOUBLE,MPI_SUM,0,MPI_COMM_WORLD);
    // tiempo final
    double end_time = MPI_Wtime();
    // Solo el rank 0 (master) imprime
    if (npes==me) {
        double pi_approx = 4.0 * h* global_sum;
        double error = fabs(M_PI - pi_approx);
        printf("Numero de ranks: %d\n", size);
        printf("Pi es aproximadamente: %.15f\n", pi_approx);
        printf("Error absoluto: %.15f\n", error);
        printf("Tiempo de ejecucion: %f segundos\n", end_time - start_time);
    }
    //Terminar MPI
    MPI_Finalize();
    return 0;
}

