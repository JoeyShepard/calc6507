#!/usr/bin/env python3

from math import sqrt, sin, cos, tan, atan, sinh, cosh, tanh, atanh

N = 64
ATAN  = [atan(2**(-i)) for i in range(N)]
ATANH = [atanh(2**(-i)) for i in range(1, N+1)]
DIV = [2**(-i) for i in range(1, N+1)]

P, d = 1.0, 1.0
for i in range(N):
    P *= (1 + d*d)
    d /= 2

K = sqrt(P)

P, d = 1.0, 0.5
for i in range(N):
    P *= (1 - d*d)
    d /= 2

KH = sqrt(P)

def cmp(a, b):
    return (a > b) - (a < b) 

def cordic(r, m, x, y, z, d, A, l=0):
    for a in A:
        if l:
            s=cmp(y,l)
        else:
            s = cmp(y, 0) if r else -cmp(z, 0)
        z += s * a
        x, y = x + m * y * s * d, y - x * s * d
        d /= 2
    return x, y, z

# Examples

# Trigonometrics
arg = 0.4
cordic(0, 1, 1/K, 0, arg, 1.0, ATAN)
# (0.9210609940028851, 0.3894183423086506, -9.860820082244643e-20)
# cos(arg) = 0.9210609940028851
# sin(arg) = 0.3894183423086506

# ArcTan
x, y = 1, 0.3
cordic(1, 1, x, y, 0, 1.0, ATAN)
# (1.719268184147658, 3.014918053875318e-21, 0.2914567944778671)
# atan(y) = 0.2914567944778671

# Polar -> Rectangle
R, arg = 4, 0.3
cordic(0, 1, R/K, 0, arg, 1.0, ATAN)
# (3.821345956502423, 1.1820808266453582, -4.126804076027055e-20)
# R cos(arg) = 3.821345956502423
# R sin(arg) = 1.1820808266453582

# Rectangle -> Polar
x, y = 4.0, 3.0
cordic(1, 1, x/K, y/K, 0, 1.0, ATAN)
# (5.0, -2.973879738250645e-19, 0.6435011087932845)
# R = 5.0
# arg = 0.6435011087932845

# Hyperbolics
arg = 0.3
cordic(0, -1, 1/KH, 0, arg, 0.5, ATANH)
# (1.0453385141288591, 0.30452029344714265, 1.6589934365363523e-20)
# cosh(arg) = 1.0453385141288591
# sinh(arg) = 0.30452029344714265
# exp(arg)  = 1.3498588075760019

# ArcTanh
x, y = 1, 0.3
cordic(1, -1, x, y, 0, 0.5, ATANH)
# (0.7915612160657626, -4.779039846398306e-21, 0.30951960420311164)
# atan(y) = 0.30951960420311164

# Square Root
w = 41.0/64 # = 0.640625
x, y = w + .25, w - 0.25
cordic(1, -1, x/KH, y/KH, 0, 0.5, ATANH)
# (0.8003905296791062, 4.1772288081155573e-20, 0.4704916722322633)
# 8 * 0.8003905296791062 = 6.403124237432849
# sqrt(41) = 6.403124237432849

# Logarithm
w = 1.3
x, y = w + 1, w - 1
cordic(1, -1, x, y, 0, 0.5, ATANH)
# (1.8921932229626461, -3.271537741499214e-20, 0.13118213223374547)
# 2 * 0.13118213223374547 = 0.26236426446749095
# log(1.3) = 0.26236426446749095

# Division
x, y = 1.3 , 0.7
cordic(1, 0, x, y, 0, 0.5, DIV)
# (1.3, 1.042502088928603e-20, 0.5384615384615383)
# y / x = 0.5384615384615383

x, y = 113.0/128, 355.0/512
cordic(1, 0, x, y, 0, 0.5, DIV)
# (0.8828125, 2.964615315390051e-21, 0.7853982300884956)
# 4 * 0.7853982300884956 = 3.1415929203539825

# Multiplication
x, z = 1.3 , 1.3
cordic(0, 0, x, 0, z, 0.5, DIV)
# (1.3, 0.9100000000000017, 0.0)
# x * z = 0.91

#Added later by me:
x=1/K
y=0
z=0
x,y,z=cordic(1, 1, x, y, z, 1.0, ATAN,0.4)
print("expected: 0.41151684606748801938473789761734")
print(f"results:  {z}")
