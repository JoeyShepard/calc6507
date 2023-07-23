#!/usr/bin/env python3

with open("processed.asm","rt") as f:
    comment_total=0
    for line in f.readlines():
        if line.startswith(";Including"):
            print()
            print("*"*10)
            print(line[len(";Including"):],end="")
            print("*"*10)
        line_state="None"
        for char in line:
            if line_state=="None":
                if char==";":
                    line_state="Comment"
            elif line_state=="Comment":
                if char.islower():
                    print(line,end="")
                    comment_total+=1
                line_state="None"
    print(comment_total,"lines in total")

            
        
