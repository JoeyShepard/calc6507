#!/usr/bin/env python3

from os import listdir

files=[file for file in listdir("./keys/") if file.endswith(".swp")==False]
files.sort()
counter=1
for file in files:
    print(f"{counter}. {file}")
    counter+=1

selection=int(input())
if selection<1 or selection>len(files):
    print("Selection out of range")
    exit(1)
else:
    file=files[selection-1]
    print("==========")
    with open(f"./keys/{file}","rt") as file_read:
        with open("keys.txt","wt") as file_write:
            for line in file_read.readlines():
                line=line[:-1]
                print(line)
                if "#" in line:
                    line=(line[:line.index("#")]).rstrip()
                if line.strip()!="":
                    file_write.write(line+"\n")
