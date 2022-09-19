from sys import argv

#Constants
#=========
VM_BEGIN="<VM"
NOVM_BEGIN="<NOVM"      #No bytes generated - for defining constants
VM_END="VM>"
BYTES_PER_LINE=8
STACK_OPS_BEGIN=208     #Beginning of stack ops encoding

#VM instruction information
#==========================
#Floating point operations
FP_OPS=[
    "DEST",
    "SRC",
    "TOS",
    "ADD"]

#Stack operations
STACK_OPS=[
    #Single byte stack ops
    None,           #0  ;Interpretting BRK ignored as NOP
    VM_END,         #1
    "!",            #2
    "DUP",          #3
    "OVER",         #4
    "I",            #5
    "1+",           #6
    "RSHIFT",       #7
    "A",            #8
    "+",            #9
    "-",            #10
    "LSHIFT",       #11
    "C!",           #12
    "DO",           #13
    "JSR",          #14
    "DROP",         #15
    "HALT",         #16
    "DEBUG",        #17
    "SWAP",         #18
    "@",            #19
    "SELECT",       #20
    "AND",          #21
    "XOR",          #22
    "C@",           #23
    "EXEC",         #24
    "VM...",        #25
    "<",            #26
    
    #Single byte ops for FP VM
    "FDROP",        #0
    "FNEW",         #1
    "FSP",          #2
    "FTOS",         #3
    
    #Single byte ops that take single byte argument
    "PUSH_RES",     #0
    "PUSH_BYTE",    #1
    "LOOP",         #2
    "IF",           #3
    "WHILE",        #4
    "ELSE"          #5
    ]
#Other operations processed but not assigned a token
OTHER_OPS=[
    "EXTERN",
    "RES",
    "CONST8",   #8-bit constant defined in assembly file
    "CONST",    #Calculated and named literal value
    "[",
    "THEN",
    "BEGIN",
    "...VM"]

#Loop constructs  
LOOP_TYPES=[
    "LOOP",
    "WHILE"]

#Match corresponding loop types
LOOP_LOOKUP={
    "LOOP":"DO",
    "WHILE":"BEGIN"}
    
STATE_LIST=[
    "extern",
    "const8",
    "immediate"]

REG_LIST=["R0","R1","R2","R3","R4","R5","R6","R7"]

#Debug information
#=================
#Arguments that have an argument byte after specifying a 16-bit constant
CONST_OPS=["PUSH_RES"]

#Arguments that have an argument byte after
ARG_OPS=[
    "PUSH_RES",
    "PUSH_BYTE",
    "LOOP",
    "IF",
    "ELSE"
    ]
usage_counts={i:0 for i in FP_OPS+STACK_OPS}
const_counts={}
fp_counts={i:[0]*8 for i in FP_OPS}

#Main code
#=========
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
        return [fp_reg+(fp_code<<3)]
    
def table_begin(f,title):
    f.write('<div style="width: fit-content;">\n')
    f.write(f"<center><b>{title}</b></center>\n")
    f.write('<table>\n')
    
def table_header(f,cells,end=True):
    f.write("<tr>")
    for cell in cells:
        f.write(f"<th>{cell}</th>")
    if end:
        table_row_end(f)

def table_row(f,cells,end=True):
    f.write("<tr>")
    for cell in cells:
        f.write(f"<td>{cell}</td>")
    if end:
        table_row_end(f)

def table_row_end(f):
    f.write("</tr>\n")
    
def table_end(f,new_lines=True):
    f.write("</table>\n")
    f.write("</div>\n")
    if new_lines:
        f.write("<br><br>\n")
    
def Hex2(number):
    return "$"+('00'+(hex(number)[2:].upper()))[-2:]
    
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

    #Constant resources encoded in a single byte
    res_found=False
    res_list=[]
    as_list={}

    #List of addresses for structures like DO and IF
    struct_list=[]

    #Internal stack used for calculations between [ and ]
    internal_stack=[]
    internal_symbols={}

    #Constant strings
    const_string=""
    const_string_list=[]
    
    #IF/THEN statements
    if_list=[]

    #Externally defined symbols
    last_extern=None
    extern_state="normal"

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
            #Line of input from file - strip comments
            split_line=[]
            for word in line.split():
                if word[0]==";":
                    break
                split_line+=[word]
            
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
                        if split_line[0].upper() in [VM_BEGIN,NOVM_BEGIN,"...VM"]:
                            file_mode="VM"
                            input_state="normal"
                            byte_list=[]
                            byte_comments=[]
                            transition_count+=1
                            if split_line[0].upper() in [VM_BEGIN,"...VM"]:
                                output_file.write(" BRK\n")
                                VM_mode="VM"
                            else:
                                VM_mode="NOVM"
                            del split_line[0]
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
                                    output_file.write(f" FCB lo(({resource}))\n")
                                output_file.write("\n")
                            output_file.write(" VM_res_table_high:\n")
                            if res_list:
                                for resource in res_list:
                                    output_file.write(f" FCB hi(({resource}))\n")
                                output_file.write("\n")
                            if const_string_list:
                                for i,string in enumerate(const_string_list):
                                    output_file.write(f" __vm_const_str{i}:\n")
                                    output_file.write(f' FCB "{string}",0\n')
                                output_file.write("\n")
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
                        if not split_line:
                            continue
                        
                        if split_line[0] in [VM_BEGIN,NOVM_BEGIN]:
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
                        elif split_line[0].upper() in STACK_OPS + OTHER_OPS or \
                        split_line[0].isnumeric() or split_line[0][0] in "$'" or \
                        split_line[0] in res_list or split_line[0] in as_list or \
                        split_line[0] in internal_symbols or \
                        split_line[0]=='"' or input_state in STATE_LIST:
                            for item in split_line:
                                if file_mode=="assembly":
                                    print(f"Error: Tokens left on line after END")
                                    print(f"Line: {line.strip()}")
                                    exit(1)
                                if input_state=="normal":
                                    if item.upper() in STACK_OPS:
                                        new_bytes=[STACK_OPS_BEGIN+STACK_OPS.index(item.upper())]
                                        byte_list+=new_bytes
                                        byte_comments+=[item]
                                        if item.upper() in [VM_END,"VM..."]:
                                            if input_state!="normal":
                                                print("Error: VM block ended with unfinished stack operation")
                                                print(f"Line: {line.strip()}")
                                                exit(1)
                                            elif len(byte_list)!=len(byte_comments):
                                                print("Error: generated bytes and comments don't match")
                                                print(f"byte_list: {byte_list}")
                                                print(f"byte_comments: {byte_comments}")
                                                exit(1)
                                            elif struct_list:
                                                print("Error: unclosed structure at end of VM block")
                                                print("Structure list:")
                                                for struct in struct_list:
                                                    print("\t",struct["type"].upper())
                                                print(f"Line: {line.strip()}")
                                                exit(1)
                                            elif if_list:
                                                print("Error: unclosed IF at end of VM block")
                                                print(f"Line: {line.strip()}")
                                                exit(1)
                                            if VM_mode=="NOVM":
                                                byte_list.pop()
                                                if byte_list!=[]:
                                                    print("Error: NOVM block closed with bytes generated")
                                                    print(f"Generated bytes: ",end="")
                                                    for i,b in enumerate(byte_list):
                                                        if i!=0:
                                                            print(", ",end="")
                                                        print(Hex2(b),end="")        
                                                    print("]")
                                                    print(f"Line: {line.strip()}")
                                                    exit(1)
                                            else:
                                                #Insert commented bytecode into source output
                                                last_byte=None
                                                comment=""
                                                MAX_LINE=" FCB XXX, CONST_NAME "
                                                for i in range(len(byte_list)):
                                                    if byte_comments[i]:
                                                        if last_byte!=None:
                                                            output=f" FCB ${hex(last_byte)[2:].upper()}"
                                                            output+=" "*(len(MAX_LINE)-len(output))
                                                            output_file.write(f"{output} ;{comment}\n")
                                                        last_byte=byte_list[i]
                                                        comment=byte_comments[i]
                                                    else:
                                                        output=f" FCB ${hex(last_byte)[2:].upper()}, "
                                                        if type(byte_list[i])==str:
                                                            output+=f"{byte_list[i]}"
                                                        else:
                                                            output+=f"${hex(byte_list[i])[2:].upper()}"
                                                        output+=" "*(len(MAX_LINE)-len(output))
                                                        output_file.write(f"{output} ;{comment}\n")
                                                        last_byte=None
                                                if last_byte!=None:
                                                    output=f" FCB ${hex(last_byte)[2:].upper()}"
                                                    output+=" "*(len(MAX_LINE)-len(output))
                                                    output_file.write(f"{output} ;{comment}\n")
                                                    
                                                #Count bytecode usage for debugging
                                                index=0
                                                while(1):
                                                    if index>=len(byte_list):
                                                        #Done processing
                                                        break
                                                    op_byte=byte_list[index] 
                                                    if op_byte<STACK_OPS_BEGIN:
                                                        #FP op
                                                        fp_code=op_byte>>3
                                                        fp_reg=op_byte&7
                                                        fp_name=FP_OPS[fp_code]
                                                        fp_counts[fp_name][fp_reg]+=1
                                                        usage_counts[fp_name]+=1
                                                    else:
                                                        #Stack op
                                                        op_byte-=STACK_OPS_BEGIN
                                                        op_name=STACK_OPS[op_byte]
                                                        usage_counts[op_name]+=1
                                                        if op_name in ARG_OPS:
                                                            if op_name in CONST_OPS:
                                                                data_byte=byte_list[index+1]
                                                                if data_byte not in const_counts:
                                                                    const_counts[data_byte]=0
                                                                const_counts[data_byte]+=1
                                                            index+=1
                                                    index+=1
                                            file_mode="assembly"
                                        elif item.upper() in LOOP_TYPES:
                                            if struct_list==[] or struct_list[-1]["type"]!=LOOP_LOOKUP[item.upper()]:
                                                print(f"Error: {item.upper()} without beginning {LOOP_LOOKUP[item.upper()]}")
                                                print(f"Line: {line.strip()}")
                                                print(f"Structure stack: {struct_list}")
                                                exit(1)
                                            byte_list+=[len(byte_list)-struct_list.pop()["len"]+1]
                                            byte_comments[-1]+=f" back {byte_list[-1]} bytes"
                                            byte_comments+=[""]
                                        elif item.upper()=="DO":
                                            struct_list+=[{"type":item.upper(), "len":len(byte_list)}]
                                        elif item.upper()=="IF":
                                            if_list+=[len(byte_list)]
                                            byte_list+=[0]      #Placeholder jump length
                                            byte_comments+=[""]
                                        elif item.upper()=="ELSE":
                                            if not if_list:
                                                print(f"Error: ELSE without matching IF")
                                                print(f"Line: {line.strip()}")
                                                exit(1)
                                            index=if_list.pop()
                                            byte_list[index]=len(byte_list)-index
                                            if_list+=[len(byte_list)]
                                            byte_list+=[0]      #Placeholder jump length
                                            byte_comments+=[""]
                                    elif item.upper() in OTHER_OPS:
                                        if item.upper()=="EXTERN":
                                            input_state="extern"
                                        elif item.upper()=="CONST8":
                                            input_state="const8"
                                        elif item=="[":
                                            input_state="immediate"
                                        elif item.upper()=="THEN":
                                            if not if_list:
                                                print(f"Error: THEN without matching IF")
                                                print(f"Line: {line.strip()}")
                                                exit(1)
                                            index=if_list.pop()
                                            byte_list[index]=len(byte_list)-index-1
                                        elif item.upper()=="BEGIN":
                                            struct_list+=[{"type":item.upper(), "len":len(byte_list)}]
                                    elif item in res_list:
                                        #Push 16-bit constant onto stack
                                        byte_list+=[STACK_OPS_BEGIN+STACK_OPS.index("PUSH_RES")]
                                        byte_list+=[res_list.index(item)]
                                        byte_comments+=[f"16-bit const {item}"]
                                        byte_comments+=[""]
                                    elif item in as_list:
                                        #Push 16-bit constant with alternate name onto stack
                                        byte_list+=[STACK_OPS_BEGIN+STACK_OPS.index("PUSH_RES")]
                                        byte_list+=[as_list[item]]
                                        byte_comments+=[f"16-bit const {item}"]
                                        byte_comments+=[""]
                                    elif item in internal_symbols:
                                        #Symbol defined in immediate mode
                                        num=internal_symbols[item]
                                        if int(num)<256:
                                            #8-bit constant
                                            byte_list+=[STACK_OPS_BEGIN+STACK_OPS.index("PUSH_BYTE")]
                                            byte_list+=[int(num)]
                                            byte_comments+=[f"8-bit const {num}"]
                                            byte_comments+=[""]
                                        else:
                                            #16-bit constant
                                            if num not in res_list:
                                                res_list+=[num]
                                            byte_list+=[STACK_OPS_BEGIN+STACK_OPS.index("PUSH_RES")]
                                            byte_list+=[res_list.index(num)]
                                            byte_comments+=[f"16-bit const {num}"]
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
                                        if int(num)<256:
                                            #8-bit constant
                                            byte_list+=[STACK_OPS_BEGIN+STACK_OPS.index("PUSH_BYTE")]
                                            byte_list+=[int(num)]
                                            byte_comments+=[f"8-bit const {num}"]
                                            byte_comments+=[""]
                                        else:
                                            #16-bit constant
                                            res_list+=[num]
                                            byte_list+=[STACK_OPS_BEGIN+STACK_OPS.index("PUSH_RES")]
                                            byte_list+=[res_list.index(num)]
                                            byte_comments+=[f"16-bit const {num}"]
                                            byte_comments+=[""]
                                    elif item[0]=="'":
                                        if len(item)!=3 or item[-1]!="'":
                                            print("Error: Invalid character: {item}")
                                            print(f"Line: {line.strip()}")
                                            exit(1)
                                        char_code=ord(item[1])
                                        byte_list+=[STACK_OPS_BEGIN+STACK_OPS.index("PUSH_BYTE")]
                                        byte_list+=[char_code]
                                        byte_comments+=[f"Character: {item}=={num}"]
                                        byte_comments+=[""]
                                    elif item=='"':
                                        const_string=""
                                        input_state="string"
                                    else:
                                        print(f"Error: VM operation not recognized: {item}")
                                        print(f"Line: {line.strip()}")
                                        exit(1)
                                elif input_state=="extern":
                                    if item.upper()=="END":
                                        if extern_state=="as":
                                            print(f"Error: AS in EXTERN block not terminated")
                                            print(f"Line: {line.strip()}")
                                            exit(1)
                                        input_state="normal"
                                    elif item.upper()=="AS":
                                        if extern_state=="as":
                                            print(f"Error: AS after AS in EXTERN block")
                                            print(f"Line: {line.strip()}")
                                            exit(1)
                                        extern_state="as"
                                    else:
                                        if extern_state=="as":
                                            as_list[item]=res_list.index(last_extern)
                                            extern_state="normal"
                                        else:
                                            if item not in res_list:
                                                #Only add address if not added yet. Not error to add again.
                                                res_list+=[item]
                                            last_extern=item
                                elif input_state=="const8":
                                    byte_list+=[STACK_OPS_BEGIN+STACK_OPS.index("PUSH_BYTE")]
                                    byte_list+=[item]
                                    byte_comments+=[f"External 8-bit const {item}"]
                                    byte_comments+=[""]
                                    input_state="normal"
                                elif input_state=="immediate":
                                    if item=="]":
                                        input_state="normal"
                                    elif item in "+-*/":
                                        if len(internal_stack)<2:
                                            print("Error: internal stack underflow on {item}")
                                            print(f"Line: {line.strip()}")
                                            exit(1)
                                        TOS=internal_stack.pop()
                                        NOS=internal_stack.pop()
                                        internal_stack+=[int(eval(f"{NOS}{item}{TOS}"))]
                                    elif item.upper()=="CONST":
                                        input_state="immediate-const"
                                    elif item.upper()=="DUMP":
                                        print(f"Internal stack: {internal_stack}")
                                    elif item in internal_symbols:
                                        internal_stack+=[internal_symbols[item]]
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
                                        internal_stack+=[num]    
                                    else:
                                        print(f"Error: VM operation not recognized: {item}")
                                        print(f"Line: {line.strip()}")
                                        exit(1)
                                elif input_state=="immediate-const":
                                    if len(internal_stack)==0:
                                        print("Error: unable to create immediate constant - stack empty")
                                        print(f"Line: {line.strip()}")
                                        exit(1)
                                    internal_symbols[item]=internal_stack.pop()
                                    input_state="immediate"
                                elif input_state=="string":
                                    if const_string:
                                        const_string+=" "
                                    if item[-1]!='"':
                                        const_string+=item.replace("\s"," ")
                                    else:
                                        const_string+=item[:-1].replace("\s"," ")
                                        if const_string not in const_string_list:
                                            const_string_list+=[const_string]
                                        str_name=f"__vm_const_str{const_string_list.index(const_string)}"
                                        res_list+=[str_name]
                                        byte_list+=[STACK_OPS_BEGIN+STACK_OPS.index("PUSH_RES")]
                                        byte_list+=[res_list.index(str_name)]
                                        byte_comments+=[f'Const string "{const_string}"']
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
    
    #Output HTML file with debug info
    with open("vm-debug.html","wt") as f:
        #CSS
        f.write("<html><head><style>\n")
        f.write("""
        * {
            font-family: monospace;
            font-size: 14px;
        }
        table, th, td {
            padding-top: 3px;
            padding-bottom: 3px;
            padding-left: 5px;
            padding-right: 5px;
            border: 1px solid black;
            border-collapse: collapse;
            }
            """)
        f.write("</style></head><body>\n")
        
        f.write('<div style="display: table;">\n')
        f.write('<div style="display: table-row;">\n')
        f.write('<div style="display: table-cell;">\n')
        
        table_begin(f,"General Stats")
        table_row(f,["VM invocations",transition_count])
        table_row(f,["Const slots used",f"{len(res_list)}/256"])
        table_end(f)
        
        #FP ops stats
        table_begin(f,"Floating Point Ops")
        table_header(f,["Bytecode","Op"]+["R"+str(i) for i in range(8)]+["Total"])
        for i,op in enumerate(FP_OPS):
            cells=[Hex2(i)]
            cells+=[op]
            table_row(f,cells,False)
            
            reg_count=0
            for reg in fp_counts[op]:
                if reg:
                    reg_count+=1
                    f.write("<td>")
                else:
                    f.write('<td style="background-color: LightGray">')
                f.write(f"{reg}</td>")
            
            if reg_count==0:
                color="LightPink"
            elif reg_count==1:
                color="LightGreen"
            else:
                color=""
            
            if color:
                f.write(f'<td style="background-color: {color}">')
            else:
                f.write("<td>")
            f.write(f"{reg_count}</td>")
            table_row_end(f)
        f.write(f'<td colspan="11">Unused: {Hex2(len(FP_OPS))}-{Hex2(int(STACK_OPS_BEGIN/8))} ({int(STACK_OPS_BEGIN/8)-len(FP_OPS)})')
        table_end(f)
        
        #Tokenized constants
        table_begin(f,"16-bit Constants")
        table_header(f,["ID","Value","Total"])
        for i,res in enumerate(res_list):
            cells=[Hex2(i)]
            cells+=[res]
            table_row(f,cells,False)
            
            if i in const_counts:
                total=const_counts[i]
            else:
                total=0
                
            if total==0:
                color="Red"
            elif total==1:
                color="LightPink"
            else:
                color=""
            
            if color:
                f.write(f'<td style="background-color: {color}">')
            else:
                f.write("<td>")
            f.write(f"{total}</td>")
            table_row_end(f)
        table_end(f)
        
        #End of first column
        f.write('</div>\n')
        f.write('<div style="display: table-cell;padding-left: 2em;">\n')
        
        #Stack op stats
        table_begin(f,"Stack Ops")
        table_header(f,["Bytecode","Op","Total"])
        for i,op in enumerate(STACK_OPS):
            cells=[Hex2(i+STACK_OPS_BEGIN)]
            cells+=[op]
            table_row(f,cells,False)
            
            total=usage_counts[op]
            if total==0:
                color="LightPink"
            else:
                color=""
            
            if color:
                f.write(f'<td style="background-color: {color}">')
            else:
                f.write("<td>")
            f.write(f"{total}</td>")
            table_row_end(f)
        if len(STACK_OPS)+STACK_OPS_BEGIN<256:
            f.write(f'<td colspan="3">Unused: {Hex2(STACK_OPS_BEGIN+len(STACK_OPS))}-$FF ({0x100-STACK_OPS_BEGIN-len(STACK_OPS)})</td>')
        table_end(f,False)
        
        f.write('</div>\n') #div table-cell
        f.write('</div>\n') #div table-row
        f.write('</div>\n') #div table
        
        f.write("</body></html>\n")
        
    #Output word names for debugging in simulator
    MAX_WORD_LEN=max([0 if x==None else len(x) for x in STACK_OPS])
    with open("vm_debug_words.asm","wt") as f:
        f.write(f"\tVM_DEBUG_WORDS_LEN: FCB {MAX_WORD_LEN+1}\n")
        f.write("\tVM_DEBUG_WORDS:\n")
        for op in STACK_OPS:
            if op==None:
                op="None"
            f.write(f'\tFCB "{(op+(" "*MAX_WORD_LEN))[:MAX_WORD_LEN]}",0\n')
            
        
if __name__=="__main__":
    main()