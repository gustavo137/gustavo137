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
# To run: python3 pi.py
from math import pi
from time import time 
# Computing pi in serial 
t_start = time()

num = 1000000
sum =0.0
width = 1.0/num 

for i in range(0, num):
  x = (float(i)+0.5) * width
  f_x = 4.0/(1.0+x*x)
  sum += f_x

t_end = time()

print("Pi is approximately ", sum*width, " versus ", pi)
print(" Error ", (sum*width) - pi)
print("Time ", t_end - t_start)
