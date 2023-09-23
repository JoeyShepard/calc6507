#!/usr/bin/env python3

#example from https://www.hpmuseum.org/forum/thread-12180.html
#modified to test implementation of atan, asin and others

#Use same method as hyperbolic to do multiple steps like in pdf
# - came back later and not sure what pdf this was

from math import sqrt, sin, cos, atan, pi
from sys import exit

DEBUG=False

CMP_SINCOS=0
CMP_ATAN=1
CMP_ASIN=2

N = 16
#original
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

def cordic(r, m, x, y, z, d, A, arg):
    iterations=1
    max_x=0
    max_y=0
    for i,a in enumerate(A):
        for j in range(9):

            if DEBUG:
                print(iterations,"-",i,'.',j,':')
                print("   X: ",x)
                print("   Y: ",y)
                print("   Z: ",z,"\n")

            if r==CMP_SINCOS:
                #sin/cos
                s=-cmp(z,0)
            elif r==CMP_ATAN:
                #arctan
                s=cmp(y,0)
            elif r==CMP_ASIN:
                #arcsin
                s=cmp(y,arg)
            z += s * a
            x, y = x + m * y * s * d, y - x * s * d
            max_x=max(x,max_x)
            max_y=max(y,max_y)
            iterations+=1
        d /= 10
    return x, y, z, max_x, max_y

# sin/cos
x=1/K
y=0
z=0.4 #arg
print("sin/cos")
print(f"expected: 0.9210609940028851, 0.38941834230865136") 
x,y,z,_,_=cordic(CMP_SINCOS, 1, x, y, z, 1.0, ATAN,0)
print(f"result:   {x}, {y}")
print()
#(0.9210609940028851, 0.38941834230865136, -2.986136694229353e-16)

# arctan
x=1
y=0.3 #arg
z=0
print("atan")
print("expected:  0.2914567944778671")
x,y,z,_,_=cordic(CMP_ATAN, 1, x, y, z, 1.0, ATAN,0)
print(f"result:    {z}")
print()
# (1.719268184147658, 3.014918053875318e-21, 0.2914567944778671)

# arcsin - see voidware example
x=1/K
y=0
z=0
arg=0.4
print("asin")
print("expected: 0.4115168460674880")
x,y,z,_,_=cordic(CMP_ASIN, 1, x, y, z, 1.0, ATAN,arg)
print((x,y,z))
print(f"result:   {z}")
print()
# Windows calc: 0.41151684606748801938473789761734
