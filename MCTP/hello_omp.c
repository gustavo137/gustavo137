#include <stdio.h>
#include <omp.h>
// Compilar con: gcc -fopenmp hello_omp.c -o hello_omp
// Exportar variable de entorno OMP_NUM_THREADS para definir el número de hilos
// Ejecutar con: ./hello_omp
int main() {
    printf("Maximo numero de hilos=: %d\n", omp_get_max_threads());

    printf("Hilo master: mundo secuencial!\n");

    #pragma omp parallel
    {
        int thread_id = omp_get_thread_num();
        printf("Hola desde el hilo %d\n", omp_get_thread_num());
    }

    printf("Regreso a master: muundo secuencial!\n");

    return 0;
}

