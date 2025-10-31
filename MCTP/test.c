#include <stdio.h>
#include <omp.h>

int main() {
    printf("Max threads: %d\n", omp_get_max_threads());

    printf("Comienzo en el mundo secuencial.!\n");

    #pragma omp parallel
    {
        int thread_id = omp_get_thread_num();
        printf("Hola desde el hilo %d\n", omp_get_thread_num());
    }

    printf("Regreso al mundo secuencial.!\n");

    return 0;
}

