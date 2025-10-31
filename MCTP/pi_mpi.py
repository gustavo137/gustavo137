# Metodo de integracion numerica para calcular el valor de pi basado en la 
# integral de la funcion f(x) = 1 / (1 + x^2)  en el intervalo [0, 1] donde la integral es igual a pi/4.
#
# Podemos aproximar la integral usando la suma de Riemann con el metodo del punto medio.
#  * 1. Dividimos el intervalo [0, 1] en N subintervalos iguales.
#  * 2. Calculamos el ancho de cada subintervalo h = 1/N.
#  * 3. Para cada subintervalo, calculamos el punto medio x_i = (i + 0.5) * h.
#  * 4. Evaluamos la funcion en el punto medio f(x_i) = 1 / (1 + x_i^2).
#  * 5. Sumamos todas las evaluaciones y multiplicamos por el ancho h para obtener la aproximacion de la integral.
#  * 6. Finalmente, multiplicamos el resultado por 4 para obtener el valor aproximado de pi.
#  *  Con N=1e8, obtenemos una aproximacion bastante precisa de pi.
#
# Computing pi in parallel using mpi4py
#%%writefile pi_mpi.py
# to run: !mpirun --oversubscribe -np 4 python3 pi_mpi.py
from mpi4py import MPI # MPI_Init() called during import
from math import pi
from time import time

comm = MPI.COMM_WORLD
rank = comm.Get_rank() # MPI_Comm_get_size()
size = comm.Get_size() # MPI_Comm_get_rank()

t_start = time()

num = 1000000
sum =0.0
width = 1.0/num 


for i in range(rank,num,size):
  x = (float(i)+0.5) * width
  f_x = 4.0/(1.0+x*x)
  sum += f_x

t_end = time()

tot_sum = comm.reduce(sum, MPI.SUM) ## defaults: root=0, tag=0

if rank == 0:
  print("Number of ranks ", size, flush=True)
  print("Pi is approximately ", tot_sum*width, " versus ", pi, flush=True)
  print(" Error ", (tot_sum*width) - pi, flush=True)
  print("Time ", t_end - t_start, flush=True)
