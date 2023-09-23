from decimal import *
import sys

E_SIGN_BIT=4000

getcontext().rounding=ROUND_HALF_UP
#getcontext().prec=10

f_input=open("temp.txt","rt")
f_output=open("output.txt","wt")

for line in f_input:
    text=line[:-1]
    print("Read: "+text)
    num=Decimal(text)
    #Nevermind, Decimal package is trash as usual :(
    #print(getcontext().to_sci_string(num))

    exp_count=1
    while num<Decimal("0.1"):
        num*=Decimal("10")
        exp_count+=1
    print("    "+" "*exp_count+str(num)[:14]+"E-"+str(exp_count))
    round_place=str(num)[14]
    print("    "+" "*exp_count+14*" "+round_place)
    if int(round_place)>=5:
        num+=Decimal("0.000000000001")
        if num>=Decimal("1"):
            num/=10
            exp_count-=1
    print("    "+" "*exp_count+str(num)[:14]+"E-"+str(exp_count))

    write_line=""
    for i in range(6):
        write_line=", "+write_line
        num*=Decimal("100")
        write_line="$"+str(int(num)).zfill(2)+write_line
        num-=int(num)
    exp_str=str((1000-exp_count)+E_SIGN_BIT).zfill(4)
    write_line+="$"+exp_str[2:]+", $"+exp_str[0:2]
    print("     "+write_line)
    print("")

    f_output.write("    FCB "+write_line+"\n")

f_input.close()
f_output.close()

