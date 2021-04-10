#example from https://www.hpmuseum.org/forum/thread-12180.html

#Use same method as hyperbolic to do multiple steps like in pdf
#Test code from forum

from math import sqrt, sin, cos, atan, pi
from sys import exit

N = 16
#original
#ATAN  = [atan(10**(-i)) for i in range(N)]
#degrees (mine)
ATAN  = [atan(10**(-i)) for i in range(N)]

P, d = 1.0, 1.0
for i in range(N):
    P *= (1 + d*d)
    d /= 10

K = sqrt(P)**9


def cmp(a, b):
    return (a > b) - (a < b) 

def r2d(x):
    return 180*x/pi

def cordic(r, m, x, y, z, d, A):
    iterations=1
    for i,a in enumerate(A):
        for j in range(9):
            #s = cmp(z, 0)
            #z -= s * a
            #x, y = x - y * s * d, y + x * s * d
            s = cmp(y, 0) if r else -cmp(z, 0)
            z += s * a
            x, y = x + m * y * s * d, y - x * s * d
            print(iterations,"-",i,'.',j,':')
            print("   X: ",x)
            print("   Y: ",y)
            print("   Z: ",z,"\n")
            iterations+=1
        d /= 10
    return x, y, z

#original
#arg = 0.4
#print(cordic(0, 1, 1/K, 0, arg, 1.0, ATAN))
#(0.9210609940028851, 0.38941834230865136, -2.986136694229353e-16)

#arg = 30
arg=pi/6
print(cordic(0, 1, 1/K, 0, arg, 1.0, ATAN))
#0.86602540378443864676372317075294, 0.5
