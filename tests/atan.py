#!/usr/bin/env python3

from math import atan,pi

#Test identity
d=1
ratio=0.1
for i in range(10):
    print(f"{ratio:<16} {atan(ratio)}")
    identity=pi/2-atan(1/ratio)
    print(" "*17+str(identity))
    ratio*=10

