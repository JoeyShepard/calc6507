from decimal import *
from random import *
from sys import exit
from os import system
getcontext().prec=12

fp = open("input.txt","wt")

MAX_VAL = "9.99999999999e999"
MIN_VAL = "1e-999"

test_count=0


def test1(amount):
    
    #numbers to try - start with edge cases
    ret_list=[
        "0",
        "1",
        MAX_VAL,
        MIN_VAL
        ]

    #generate random number strings
    for i in range(amount):
    #20 - 310k file, 28k lines, gen: 1s
    #100 - 7.59mb, 652k lines, gen: 3s, run: 19s
    #500 - 184mb, 16m lines, gen:75s, run: ~8min
        #passed ~4m tests!

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

        ret_list+=[digits[0]+"."+digits[1:]+"e"+exp]
        ret_list+=["-"+digits[0]+"."+digits[1:]+"e"+exp]
        ret_list+=[digits[0]+"."+digits[1:]+"e-"+exp]
        ret_list+=["-"+digits[0]+"."+digits[1:]+"e-"+exp]

    return ret_list

def write_list(which_list):    
    for n,i in enumerate(which_list):
        print("Writing to file ("+str(n)+"/"+str(len(which_list)))
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
            sum_try="{:e}".format(Decimal(sum_dec)).replace("+","")
            fp.write(sum_try+"\n")        
    fp.close()
    
while(1):
    #STEP 1 - randomized round robin
    print("Test 1: randomized round robin")
    print(f'Total tests: {test_count:,}')
    num_list=test1(100)
    test_count+=len(num_list)**2
    system('"..\\..\\..\\projects\\6502 emu\\node.js\\run.bat"')
    break
