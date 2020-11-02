from decimal import *
from random import *
from sys import exit
getcontext().prec=12

fp = open("input.txt","wt")

MAX_VAL = "9.99999999999e999"
MIN_VAL = "1e-999"

#numbers to try - start with edge cases
num_list=[
    "0",
    "1",
    MAX_VAL,
    MIN_VAL
    ]

#generate random number strings
for i in range(20):
#20 - 310k file, 28k lines, gen: 1s, run: 
    
    #digits
    digit_count=randint(1,12)
    digits=""
    for j in range(digit_count):
        digits+=str(randint(0,9))

    #exponent
    exp_count=randint(1,3)
    exp=""
    for j in range(exp_count):
        exp+=str(randint(0,9))

    num_list+=[digits[0]+"."+digits[1:]+"e"+exp]
    num_list+=["-"+digits[0]+"."+digits[1:]+"e"+exp]
    num_list+=[digits[0]+"."+digits[1:]+"e-"+exp]
    num_list+=["-"+digits[0]+"."+digits[1:]+"e-"+exp]

for i in num_list:
    for j in num_list:
        fp.write("A\n")
        fp.write(i+"\n")
        fp.write(j+"\n")
        sum_dec=Decimal(i)+Decimal(j)
        if sum_dec>Decimal(MAX_VAL):
            #print("over:",sum_dec)
            sum_dec=Decimal(MAX_VAL)
        elif sum_dec!=Decimal(0) and abs(sum_dec)<Decimal(MIN_VAL):
            #print("under:",sum_dec)
            sum_dec=Decimal(MIN_VAL)
        #sum_try=str("%e" % sum_dec.normalize()).replace("+","").replace("E","e")
        sum_try="{:e}".format(Decimal(sum_dec)).replace("+","")
        fp.write(sum_try+"\n")
            

fp.close()
    
