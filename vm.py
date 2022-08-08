from sys import argv

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
    print(f"Could not open {argv[1]} for input")
    exit(1)

#Make sure file given on command line as output file can be opened    
try:
    output_file=open(argv[2],"wt")
except:
    print(f"Could not open {argv[2]} for output")
    exit(1)

#List of included files not yet finished processing
input_list=[input_file]

#Whether in assembly mode or VM translation mode
file_mode="assembly"

#Count of times jumping into VM mode
transition_count=0

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
                print(f"Could not open included file {split_line[1]}.")
                exit(1)
        else:
            #Line from included file
            if file_mode=="assembly":
                if split_line:
                    if split_line[0].upper()=="VM":
                        file_mode="VM"
                        del split_line[0]
                        transition_count+=1
            if file_mode=="assembly":
                output_file.write(line)
            elif file_mode=="VM":
                for item in split_line:
                    if item.upper()=="END":
                        file_mode="assembly"
                    else:
                        output_file.write(f" FCB {item}\n")
                        
#Done processing files
#print(f"Calls into VM: {transition_count}")
#print(f"BRK would save {transition_count*2} bytes")
                
                
            
            