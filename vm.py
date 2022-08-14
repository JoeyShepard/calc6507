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
FP_OPS=["ADD"]

#Stack operations
STACK_OP_LIST=[
    VM_END,
    "TEST"]
STACK_OPS={}
for i,op in enumerate(STACK_OP_LIST):
    STACK_OPS[op]=STACK_OPS_BEGIN+i


#Main code
#=========
def fp_token(split_line):
    return [1]
    
def stack_token(item):
    return [STACK_OPS[item]]

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
            if split_line and split_line[0]=="include":
                try:
                    #Try to open file from include statement
                    input_list+=[open(split_line[1],"rt")]
                except:
                    print(f"Error: Could not open included file {split_line[1]}")
                    exit(1)
            else:
                #Line from included file
                if file_mode=="assembly":
                    if split_line:
                        if split_line[0].upper()==VM_BEGIN:
                            file_mode="VM"
                            del split_line[0]
                            transition_count+=1
                            output_file.write(" BRK\n")
                        elif split_line[0].upper()==VM_END:
                            print("Error: VM closing token found without opening token")
                            print(f"Line: {line.strip()}")
                            exit(1)
                if file_mode=="assembly":
                    output_file.write(line)
                elif file_mode=="VM":
                    if split_line:
                        if split_line[0]==VM_BEGIN:
                            print("Error: VM opening token found in open block")
                            print(f"Line: {line.strip()}")
                            exit(1)
                        elif split_line[0].upper() in FP_OPS:
                            new_bytes=fp_token(split_line)
                            if new_bytes==None:
                                print(f"Line: {line.strip()}")
                                exit(1)
                            else:
                                byte_list+=new_bytes
                        elif split_line[0].upper() in STACK_OPS:
                            for item in split_line:
                                if file_mode=="assembly":
                                    print(f"Error: Tokens left on line after END")
                                    print(f"Line: {line.strip()}")
                                    exit(1)
                                new_bytes=stack_token(item.upper())
                                if new_bytes==None:
                                    print(f"Line: {line.strip()}")
                                    exit(1)
                                else:
                                    byte_list+=new_bytes
                                if item.upper()==VM_END:
                                    byte_count=0
                                    output_string=""
                                    for byte in byte_list:
                                        if output_string:
                                            output_string+=", "
                                        output_string+=str(byte)
                                        byte_count+=1
                                        if byte_count==BYTES_PER_LINE:
                                            output_file.write(f" FCB {output_string}\n")
                                            byte_count=0
                                            output_string=""
                                    if byte_count:
                                        output_file.write(f" FCB {output_string}\n")
                                    file_mode="assembly"
                        elif False:
                            #TODO: Check for number
                            pass
                        else:
                            print("Error: first symbol on line not recognized")
                            print(f"Line: {line.strip()}")
                            exit(1)

    #Done processing files
    if file_mode=="VM":
        print("Error: VM block unclosed at end of file")
        exit(1)
    
    #Stats for bytes generated
    print(f"VM invocations: {transition_count}")

if __name__=="__main__":
    main()