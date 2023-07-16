#!/usr/bin/env python3

try:
    while(1):
        data=input()
        data="".join([c for c in data if c.upper() in "1234567890ABCDEF"])
        for i in range(0,len(data),2):
            print(chr(int(data[i:i+2],16)),end="")
        print()
except KeyboardInterrupt:
    exit(0)
