from decimal import *
from random import *
from sys import exit
from os import system
getcontext().prec=12

MAX_VAL = "9.99999999999e999"
MIN_VAL = "1e-999"
MAX_NEG_VAL = "-9.99999999999e999"
MIN_NEG_VAL = "-1e-999"

#Randomized round robin
TEST1_COUNT = 350
    #350 = 1.96m tests
    #500 = 4m tests

#Randomized pairs - whole exponent range
TEST2_COUNT = 2000
    #2000 = 2m tests
    #4000 = 4m tests

#Tests to perform
TEST_LIST = ["A","M"]
TEST_FUNCS = [lambda a,b: a+b,
              lambda a,b: a*b]

test_count=0
rand_seed=0

def rand_num():
    #digits
    digit_count=randint(0,12)
    digits=str(randint(1,9))
    for j in range(digit_count):
        digits+=str(randint(0,9))

    #exponent
    exp_count=randint(1,3)
    exp=""
    for j in range(exp_count):
        exp+=str(randint(0,9))

    return digits, exp

def test1(amount):
    
    #numbers to try - start with edge cases
    ret_list=[
        "0",
        "1",
        MAX_VAL,
        MIN_VAL,
        MAX_NEG_VAL,
        MIN_NEG_VAL
        ]

    #generate random number strings
    for i in range(amount):
    #20 - 310k file, 28k lines, gen: 1s
    #100 - 7.59mb, 652k lines, gen: 3s, run: 19s
    #500 - 184mb, 16m lines, gen: 75s, run: ~8min

        digits,exp=rand_num()

        ret_list+=[digits[0]+"."+digits[1:]+"e"+exp]
        ret_list+=["-"+digits[0]+"."+digits[1:]+"e"+exp]
        ret_list+=[digits[0]+"."+digits[1:]+"e-"+exp]
        ret_list+=["-"+digits[0]+"."+digits[1:]+"e-"+exp]

    return ret_list

def test2(amount):

    EXP_RANGE=16
    EXP_MAX=1000-EXP_RANGE

    ret_list=[]
    for i in range(amount):
    #4000 - 176mb, 16m lines, gen: 62s, run: ~8min

        d1,e1=rand_num()
        d2,e2=rand_num()

        e1=int(e1)
        if e1>EXP_MAX:
            e1=EXP_MAX
        if randint(0,1):
            e1=-e1
            
        for i in range(EXP_RANGE):
            for j in range(EXP_RANGE):
                ret_list+=[(d1[0]+"."+d1[1:]+"e"+str(e1+i),d2[0]+"."+d2[1:]+"e"+str(e1+j))]
                ret_list+=[("-"+d1[0]+"."+d1[1:]+"e"+str(e1+i),d2[0]+"."+d2[1:]+"e"+str(e1+j))]
                ret_list+=[(d1[0]+"."+d1[1:]+"e"+str(e1+i),"-"+d2[0]+"."+d2[1:]+"e"+str(e1+j))]
                ret_list+=[("-"+d1[0]+"."+d1[1:]+"e"+str(e1+i),"-"+d2[0]+"."+d2[1:]+"e"+str(e1+j))]
        
    return ret_list

def sum_filter(sum_dec):
    if sum_dec>Decimal(MAX_VAL):
        sum_dec=Decimal(MAX_VAL)
    elif sum_dec<Decimal(MAX_NEG_VAL):
        sum_dec=Decimal(MAX_NEG_VAL)
    elif sum_dec==Decimal(0):
        #prevent 0e-1000
        sum_dec=Decimal(0)
    elif abs(sum_dec)<Decimal(MIN_VAL):
        #print("under:",sum_dec)
        sum_dec=Decimal(0)

    return sum_dec

def write_list_rr(which_list):
    #fp = open("input.txt","wt")
    fp = open("Z:\\input.txt","wt")
    
    for n,i in enumerate(which_list):
        print(chr(13)+"Writing to file ("+str(n+1)+"/"+str(len(which_list))+")",end="")
        for j in which_list:
            for k,test in enumerate(TEST_LIST):
                fp.write(test+"\n")
                fp.write(i+"\n")
                fp.write(j+"\n")

                #round input up
                getcontext().rounding=ROUND_HALF_UP
                n1=Decimal(i)+Decimal(0)
                n2=Decimal(j)+Decimal(0)
                
                #round half even for addition
                getcontext().rounding=ROUND_HALF_EVEN
                sum_dec=sum_filter(TEST_FUNCS[k](n1,n2))
                sum_try="{:e}".format(Decimal(sum_dec)).replace("+","")
                fp.write(sum_try+"\n")
    fp.write("Z")
    fp.close()
    print()

def write_list_seq(which_list):
    list_100_part=int(len(which_list)/100)

    #fp = open("input.txt","wt")
    fp = open("Z:\\input.txt","wt")
    
    for n,i in enumerate(which_list):
        if n%list_100_part==0:
             print(chr(13)+"Writing to file ("+str(n)+"/"+str(len(which_list))+")",end="")
        for k,test in enumerate(TEST_LIST):
            fp.write(test+"\n")
            fp.write(i[0]+"\n")
            fp.write(i[1]+"\n")

            #round input up
            getcontext().rounding=ROUND_HALF_UP
            n1=Decimal(i[0])+Decimal(0)
            n2=Decimal(i[1])+Decimal(0)
                
            #round half even for addition
            getcontext().rounding=ROUND_HALF_EVEN
            sum_dec=sum_filter(TEST_FUNCS[k](n1,n2))
            sum_try="{:e}".format(Decimal(sum_dec)).replace("+","")
            fp.write(sum_try+"\n")        
    fp.write("Z")
    fp.close()
    print()

print("Passed through 88") 
rand_seed=input("Seed? (default: 0) ")
if rand_seed=="":
    rand_seed=0
else: rand_seed=int(rand_seed)
    
while(1):
    #Seed so don't lose progress if program stops
    seed(rand_seed)
    print("\n\n");
    print("*****************");
    print("RANDOM SEED:",rand_seed,"")
    print("*****************");
    rand_seed+=1
    print(f'Total tests: {test_count:,}\n')
    
    #TEST 1 - randomized round robin
    print("Test 1: randomized round robin")
    
    num_list=test1(TEST1_COUNT)
    test_count+=(len(num_list)**2)*len(TEST_LIST)
    write_list_rr(num_list)

    system('copy input.txt "..\\..\\..\\projects\\6502 emu\\node.js\\input.txt" > nul')
    
    #Run tests through node.js
    system('"..\\..\\..\\projects\\6502 emu\\node.js\\run.bat"')

    #TEST 2 - randomized pairs
    print("\n\nTest 2: randomized pairs")
    
    num_list=test2(TEST2_COUNT)
    test_count+=len(num_list)*len(TEST_LIST)
    write_list_seq(num_list)

    system('copy input.txt "..\\..\\..\\projects\\6502 emu\\node.js\\input.txt" > nul')
    
    #Run tests through node.js
    system('"..\\..\\..\\projects\\6502 emu\\node.js\\run.bat"')

    
