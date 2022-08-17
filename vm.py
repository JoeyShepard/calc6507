from sys import argv

#Constants
#=========
VM_BEGIN="<VM"
VM_END="VM>"
BYTES_PER_LINE=8
STACK_OPS_BEGIN=240     #Beginning of stack ops encoding

#VM instruction information
#==========================
#Floating point operations
FP_OPS=[
    "REG",
    "ADD"]

#Stack operations
STACK_OPS=[
    #First tokens take no arguments
    VM_END,     #0
    "!",        #1
    "DUP",      #2
    "OVER",     #3
    "INV",      #4
    "1+",       #5
    #Second set takes one byte argument
    "JSR",
    "PUSH_RES",
    "LOOP2"]
    
#Other operations processed but not assigned a token
OTHER_OPS=[
    "EXTERN",
    "RES",
    "DO"]

#Main code
#=========
REG_LIST=["R0","R1","R2","R3","R4","R5","R6","R7"]
def fp_token(split_line):
    if len(split_line)!=2:
        print("Error: Wrong register instruction format")
        return None
    elif split_line[1].upper() not in REG_LIST:
        print(f"Error: Unknown register: {split_line[1]}")
        return None
    else:
        fp_code=FP_OPS.index(split_line[0].upper())
        fp_reg=REG_LIST.index(split_line[1].upper())
        return [fp_code+(fp_reg<<5)]
    
def main():
    #Print usage and exit if no command line options or more than one
    if len(argv)!=3:
        print("Calc6507 Virtual Machine Processor")
        print("Usage: vm input output")
        print("Reads in input file and recursively searches any included files for virtual machine instructions to translate. ", end="")
        print("Outputs combined and translated file to output file.")
        exit(1)

    #Make sure file given on command line as input file can be opened
    try:
        input_file=open(argv[1],"rt")
    except:
        print(f"Error: Could not open {argv[1]} for input")
        exit(1)

    #Make sure file given on command line as output file can be opened    
    try:
        output_file=open(argv[2],"wt")
    except:
        print(f"Error: Could not open {argv[2]} for output")
        exit(1)

    #List of included files not yet finished processing
    input_list=[input_file]

    #Whether in assembly mode or VM translation mode
    file_mode="assembly"

    #Count of times jumping into VM mode
    transition_count=0

    #Bytes generated below to be written to file
    byte_list=[]
    byte_comments=[]

    #Constant resources encoded in a single byte
    res_found=False
    res_list=[]

    #List of addresses for DO loops
    do_list=[]

    #Loop through all included files
    while True:
        line=input_list[-1].readline()
        if not line:
            #File end reached. Remove from list of files.
            input_list.pop()
            if not input_list:
                #No more files in list. Stop looping.
                break
        else:
            #Line of input from file
            split_line=line.split()
            
            #Process included files
            if split_line and split_line[0]=="include":
                try:
                    #Try to open file from include statement
                    input_list+=[open(split_line[1],"rt")]
                except:
                    print(f"Error: Could not open included file {split_line[1]}")
                    exit(1)
            else:
                #Line from included file
                split_line=line.split()
                if file_mode=="assembly":
                    if split_line:
                        if split_line[0].upper()==VM_BEGIN:
                            file_mode="VM"
                            input_state="normal"
                            del split_line[0]
                            transition_count+=1
                            output_file.write(" BRK\n")
                        elif split_line[0].upper()==VM_END:
                            print("Error: VM closing token found without opening token")
                            print(f"Line: {line.strip()}")
                            exit(1)
                        elif split_line[0].upper()=="<VM-RES>":
                            if res_found:
                                print("Error: Constant resource table already defined")
                                print(f"Line: {line.strip()}")
                                exit(1)
                            if len(res_list)>256:
                                print("Error: More than 256 constants defined. Ran out of room in table.")
                                print(f"Line: {line.strip()}")
                                exit(1)
                            output_file.write(" VM_res_table_low:\n")
                            if res_list:
                                for resource in res_list:
                                    output_file.write(f" FCB lo({resource})\n")
                                output_file.write("\n")
                            output_file.write(" VM_res_table_high:\n")
                            if res_list:
                                for resource in res_list:
                                    output_file.write(f" FCB hi({resource})\n")
                            res_found=True
                        else:
                            output_file.write(line)
                if file_mode=="VM":
                    if split_line:
                        #Filter out comments
                        temp_line=[]
                        for item in split_line:
                            if item[0]==";":
                                break
                            else:
                                temp_line+=[item]
                        split_line=temp_line
                                
                        if split_line[0]==VM_BEGIN:
                            print("Error: VM opening token found in open block")
                            print(f"Line: {line.strip()}")
                            exit(1)
                        elif split_line[0].upper() in FP_OPS:
                            if input_state!="normal":
                                print("Error: Unfinished stack instruction before register instruction")
                                print(f"Line: {line.strip()}")
                                exit(1)
                            new_bytes=fp_token(split_line)
                            if new_bytes==None:
                                print(f"Line: {line.strip()}")
                                exit(1)
                            else:
                                byte_list+=new_bytes
                                byte_comments+=[" ".join(split_line)]
                        elif split_line[0].upper() in STACK_OPS + OTHER_OPS or split_line[0].isnumeric() or split_line[0][0]=="$" or split_line[0] in res_list:
                            for item in split_line:
                                if file_mode=="assembly":
                                    print(f"Error: Tokens left on line after END")
                                    print(f"Line: {line.strip()}")
                                    exit(1)
                                if input_state=="normal":
                                    if item.upper() in STACK_OPS:
                                        new_bytes=[STACK_OPS_BEGIN+STACK_OPS.index(item.upper())]
                                        if item.upper()=="JSR":
                                            input_state="JSR"
                                        byte_list+=new_bytes
                                        byte_comments+=[item]
                                        if item.upper()==VM_END:
                                            if input_state!="normal":
                                                print("Error: VM block ended with unfinished stack operation")
                                                print(f"Line: {line.strip()}")
                                                exit(1)
                                            elif len(byte_list)!=len(byte_comments):
                                                print("Error: generated bytes and comments don't match")
                                                print(f"byte_list: {byte_list}")
                                                print(f"byte_comments: {byte_comments}")
                                                exit(1)
                                            elif do_list:
                                                print("Error: DO without corresonding LOOP at end of VM block")
                                                print(f"Line: {line.strip()}")
                                                exit(1)
                                            last_byte=None
                                            comment=""
                                            MAX_LINE=" FCB XXX, XXX "
                                            for i in range(len(byte_list)):
                                                if byte_comments[i]:
                                                    if last_byte!=None:
                                                        output=f" FCB ${hex(last_byte)[2:].upper()}"
                                                        output+=" "*(len(MAX_LINE)-len(output))
                                                        output_file.write(f"{output} ;{comment}\n")
                                                    last_byte=byte_list[i]
                                                    comment=byte_comments[i]
                                                else:
                                                    output=f" FCB ${hex(last_byte)[2:].upper()}, ${hex(byte_list[i])[2:].upper()}"
                                                    output+=" "*(len(MAX_LINE)-len(output))
                                                    output_file.write(f"{output} ;{comment}\n")
                                                    last_byte=None
                                            if last_byte!=None:
                                                output=f" FCB ${hex(last_byte)[2:].upper()}"
                                                output+=" "*(len(MAX_LINE)-len(output))
                                                output_file.write(f"{output} ;{comment}\n")
                                            file_mode="assembly"
                                        elif item.upper()=="LOOP2":
                                            if not do_list:
                                                print("Error: LOOP2 without beginning DO")
                                                print(f"Line: {line.strip()}")
                                                exit(1)
                                            byte_list+=[len(byte_list)-do_list.pop()+1]
                                            byte_comments[-1]+=f" back {byte_list[-1]} bytes"
                                            byte_comments+=[""]
                                    elif item.upper() in OTHER_OPS:
                                        if item.upper()=="EXTERN":
                                            input_state="extern"
                                        elif item.upper()=="DO":
                                            do_list+=[len(byte_list)]
                                    elif item in res_list:
                                        #Push 16-bit constant onto stack
                                        byte_list+=[STACK_OPS_BEGIN+STACK_OPS.index("PUSH_RES")]
                                        byte_list+=[res_list.index(item)]
                                        byte_comments+=[f"Const {item}"]
                                        byte_comments+=[""]
                                    elif item.isnumeric() or item[0]=="$":
                                        #Number not in resource list so add
                                        if item[0]=="$":
                                            #Possible hex input - try to convert
                                            try:    
                                                num=str(int(item[1:],16))
                                            except:
                                                print("Error: Invalid hex: {item}")
                                                print(f"Line: {line.strip()}")
                                                exit(1)
                                        else:
                                            num=item
                                        res_list+=[num]
                                        byte_list+=[STACK_OPS_BEGIN+STACK_OPS.index("PUSH_RES")]
                                        byte_list+=[res_list.index(num)]
                                        byte_comments+=[f"Const {num}"]
                                        byte_comments+=[""]
                                    else:
                                        print(f"Error: VM operation not recognized: {item}")
                                        print(f"Line: {line.strip()}")
                                        exit(1)
                                elif input_state=="extern":
                                    if item not in res_list:
                                        #Only add address if not added yet. Not error to add again.
                                        res_list+=[item]
                                    input_state="normal"
                                elif input_state=="JSR":
                                    if item not in res_list:
                                        print(f"Error: JSR target not found: {item}")
                                        print(f"Line: {line.strip()}")
                                        exit(1)
                                    byte_list+=[res_list.index(item)]
                                    byte_comments+=[""]
                                    input_state="normal"
                        
                        else:
                            print("Error: first symbol on line not recognized")
                            print(f"Line: {line.strip()}")
                            exit(1)

    #Done processing files
    if file_mode=="VM":
        print("Error: VM block unclosed at end of file")
        exit(1)
    elif res_list and not res_found:
        print("Error: Constant resources used but no <VM-RES> statement in source to output table")
        exit(1)
    
    #Stats for bytes generated
    print(f"VM invocations: {transition_count}")

if __name__=="__main__":
    main()