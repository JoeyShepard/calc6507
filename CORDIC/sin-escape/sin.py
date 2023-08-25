#!/usr/bin/env python3

from math import sin,pi

low=0
high=pi/2
x=pi/4
last_x=0
def zero(num):
    return f"{num:01.12f}"

while(1):
    result=sin(x)
    diff=round(result-x,12)
    print(f"{zero(x)}, {zero(result)}, {zero(diff)}")
    if diff==0:
        #Below breakpoint, search higher
        low=x
        x=x+(high-x)/2
    else:
        #Above breakpoint, search lower
        high=x
        x=low+(x-low)/2
    if x==last_x:
        exit(0)
    last_x=x

print("Result: x diverges from sin(x) at 0.000144 radians which is 0.008 degrees, so not useful")
