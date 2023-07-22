#!/usr/bin/env python3

from sys import path
from os.path import expanduser
path.append(expanduser("~/python/"))

#from color import *

def test_mult(a,b,show):
    total=0
    for i in range(16):
        if show:
            print(a,b,end=" ")
        if a&1:
            total=(total+b)&0xFFFF
        a>>=1
        b=(b<<1)&0xFFFF
        if show:    
            print(total)
    return total

for i in range(0x10000):
    #if i % 0x100==0:
    #    print(f"{int(i/0x100)}%")
    print(i)
    for j in range(0x10000):
        if test_mult(i,j,False)!=(i*j)&0xFFFF:
            print("Mismatch!")
            print(f"{i}*{j} != {test_mult(i,j,True)}")
            exit(1)
print("Done")
