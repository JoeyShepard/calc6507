from decimal import *

getcontext().rounding=ROUND_HALF_UP
#getcontext().prec=10

f_input=open("temp.txt","rt")
f_output=open("output.txt","wt")

for line in f_input:
    text=line[:-1]
    print(text)
    num=Decimal(text[:-1])
    if int(text[-1])>=5:
        num+=Decimal("0.0000000001")
    #Print all digits
    write_line=""
    print("\n")
    for _ in range(6):
        num*=100
        print(num)
        write_line+=str(int(num)).zfill(2)
        print(str(int(num)).zfill(2)+" ")
        num%=Decimal('1')
        print(num)
    
    f_output.write(write_line+"\n")
    
f_input.close()
f_output.close()

