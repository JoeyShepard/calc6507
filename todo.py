import sys

def process(filename):
    f=open(filename,"r")
    filename_printed=False

    output=""
    
    for line in f:
        split_line=line.split()
        if len(split_line)>=2:
            if split_line[0]=="include":
                process(split_line[1])
        if len(split_line)>=1:
            if split_line[0].upper() in ["TODO","TODO:"]:
                if filename_printed==False:
                    output+="\n"+filename+":"
                    filename_printed=True
                output+="\n - "+" ".join(split_line[1:])

    if output!="":
        print(output)
    
process(sys.argv[1])
