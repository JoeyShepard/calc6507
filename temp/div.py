a=123456789023
b=234567890134

ans=0

counter=14
while counter:
    if a>=b:
        ans+=1
        a-=b
        print(15-counter,a,ans)
    else:
        a*=10
        ans*=10
        counter-=1


        
    
       
