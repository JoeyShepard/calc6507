from decimal import *
import sys

getcontext().rounding=ROUND_HALF_UP
#getcontext().prec=10

f_input=open("temp.txt","rt")
f_output=open("output.txt","wt")

for line in f_input:
    text=line[:-1]
    print("\nRead: "+text)
    num=Decimal(text)
    if int(text[-1])>=5:
        print("Rounding: "+str(num))
        num+=Decimal("0.00000000001")
        print("Rounded: "+str(num))
        
    #Print all digits
    write_line=""
    num*=10
    for _ in range(6):
        print(num)
        if write_line!="":
            write_line=", "+write_line
        write_line="$"+str(int(num)).zfill(2)+write_line
        print(str(int(num)).zfill(2))
        num%=Decimal('1')
        num*=100
        print(num)

    write_line+=", $00"
    
    print(write_line+"\n")
    f_output.write("    FCB "+write_line+"\n")

f_input.close()
f_output.close()

