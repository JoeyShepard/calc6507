from decimal import *

print("Multiplication tests")

pairs=[["100000000001","1.5"],
       ["-100000000001","1.5"],
       ["100000000001","1.501"],
       ["-100000000001","1.501"],
       ["100000000001","1.4"],
       ["-100000000001","1.4"],
       ["100000000001","2.5"],
       ["-100000000001","2.5"],
       ["100000000001","2.501"],
       ["-100000000001","2.501"],
       ["100000000001","2.4"],
       ["-100000000001","2.4"]]
       
for pair in pairs:
    getcontext().prec=15
    print(Decimal(pair[0])*Decimal(pair[1]))
    getcontext().prec=12
    print(Decimal(pair[0])*Decimal(pair[1]))
    print()



print("Addition tests")
add_pairs=[["123456789012","0.5"],
           ["123456789012","0.501"],
           ["-123456789012","0.5"],
           ["-123456789012","0.501"],
           ["123456789013","0.5"],
           ["123456789013","0.501"],
           ["-123456789013","0.5"],
           ["-123456789013","0.501"]
           ]

getcontext().prec=12
for pair in add_pairs:
    print(pair[0],"+",pair[1],"=",Decimal(pair[0])+Decimal(pair[1]))
    print(pair[0],"-",pair[1],"=",Decimal(pair[0])-Decimal(pair[1]))
    print()
