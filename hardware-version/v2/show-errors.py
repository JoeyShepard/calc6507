#!/usr/bin/env python3

import sys,os

with open(sys.argv[1],"r") as f:
    for line in f:
        if len(line)==1 and ord(line)==10:
            pass
        elif line[:6]=="> > > ":
            error_file=line[6:line.find("(")]
            line_num=int(line[line.find("(")+1:line.find(")")])
            print(line[:-1])
            with open(error_file,"rt") as ef:
                for i in range(line_num-3):
                    ef.readline()
                for i in range(5):
                    print("> " if i==2 else "  ",end="")
                    print(f"{line_num-2+i}  {ef.readline()[:-1].replace(chr(9),'  ')}")
            exit(1)
        else:
            print("Unknown error type in assembler error output:")
            print(line)
            exit(1)
    exit(0)
