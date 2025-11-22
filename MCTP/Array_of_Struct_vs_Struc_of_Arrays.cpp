#include <iostream>
#include <vector>
#include <cmath>       // for sin()
#include <ctime>
#include <sys/time.h>

#ifdef _OPENMP
  #include <omp.h>
#endif

// using namespace std;
// compilation:
// g++-15 -O3 -fopenmp -march=native Array_of_Struct_vs_Struc_of_Arrays.cpp -o aos_soa.x
// to get compilation info:
// g++-15 -O3 -fopenmp -march=native -fopt-info-vec Array_of_Struct_vs_Struc_of_Arrays.cpp -o aos_soa.x


// ========================
// Array of Structures (AoS)
// ========================
// No vectorization
// Each element has its own copy of 'density' and 'momentum'.
// In memory: [ρ₀,m₀][ρ₁,m₁][ρ₂,m₂]...
struct StateAoS {
   double density;
   double momentum;
};

// ========================
// Structure of Arrays (SoA)
// ========================
// Vectorization
// Data grouped by type.
// In memory: [ρ₀,ρ₁,ρ₂,...] separated from [m₀,m₁,m₂,...]
struct StateSoA {
   std::vector<double> density;
   std::vector<double> momentum;
};

// ============================================
// Simple vectorizable function
// ============================================
inline double f(double x){
    return x + 1.001;
}

int main() {

    const int n = 100000000; // problem size
    double wtime1, wtime2;
    clock_t t1, t2;
    struct timeval tv1, tv2; 
    struct timezone tz;

#ifdef _OPENMP
    std::cout << "OpenMP-parallel with " << omp_get_max_threads() << " threads" << std::endl;
#endif

    // --------------------------
    // Initialize both data types
    // --------------------------
    std::vector<StateAoS> v_aos(n);
    StateSoA v_soa;
    v_soa.density.resize(n);
    v_soa.momentum.resize(n);

    for (int i = 0; i < n; i++) {
        v_aos[i].density = i * 0.001;
        v_aos[i].momentum = i * 0.002;
        v_soa.density[i]  = i * 0.001;
        v_soa.momentum[i] = i * 0.002;
    }

    // ======================================================
    // ---  Array of Structures (AoS) - poor vectorization
    // Memory access |x| | | |x| | | |x| | | |
    // ======================================================
    gettimeofday(&tv1, &tz);
    t1 = clock();
#ifdef _OPENMP
    wtime1 = omp_get_wtime();
#endif

#pragma omp simd
    for (int i = 0; i < n; i++) {
        v_aos[i].density = f(v_aos[i].density);
    }

    t2 = clock();
#ifdef _OPENMP
    wtime2 = omp_get_wtime();
#endif
    gettimeofday(&tv2, &tz);

    std::cout << "\n=== AoS Results (poor vectorization) ===" << std::endl;
    std::cout << "density[0] = " << v_aos[0].density << std::endl;
    std::cout << "CPU time (clock)                = " << (t2 - t1) / 1.0e6 << " sec" << std::endl;
#ifdef _OPENMP
    std::cout << "wall clock time (omp_get_wtime) = " << wtime2 - wtime1 << " sec" << std::endl;
#endif
    std::cout << "wall clock time (gettimeofday)  = "
         << (tv2.tv_sec - tv1.tv_sec) + (tv2.tv_usec - tv1.tv_usec) * 1e-6 << " sec" << std::endl;

    // ======================================================
    // ---  Structure of Arrays (SoA) - vectorization-friendly
    // Memory access |x|x|x | | | | | | | | | |
    // ======================================================
    gettimeofday(&tv1, &tz);
    t1 = clock();
#ifdef _OPENMP
    wtime1 = omp_get_wtime();
#endif

#pragma omp simd
    for (int i = 0; i < n; i++) {
        v_soa.density[i] = f(v_soa.density[i]);
    }

    t2 = clock();
#ifdef _OPENMP
    wtime2 = omp_get_wtime();
#endif
    gettimeofday(&tv2, &tz);

    std::cout << "\n=== SoA Results (friendly vectorization) ===" << std::endl;
    std::cout << "density[0] = " << v_soa.density[0] << std::endl;
    std::cout << "CPU time (clock)                = " << (t2 - t1) / 1.0e6 << " sec" << std::endl;
#ifdef _OPENMP
    std::cout << "wall clock time (omp_get_wtime) = " << wtime2 - wtime1 << " sec" << std::endl;
#endif
    std::cout << "wall clock time (gettimeofday)  = "
         << (tv2.tv_sec - tv1.tv_sec) + (tv2.tv_usec - tv1.tv_usec) * 1e-6 << " sec" << std::endl;

    std::cout << "\nDone.\n";
    return 0;
}

