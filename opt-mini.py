from sys import argv

#Parses one or more arguments separated by commas
def arg_parse(arg_list,error_obj):
    comma=False
    ret_val=[]
    for arg in arg_list[1:]:
        if not comma:
            ret_val+=[arg]
        else:
            pass
        comma=not comma
    if not comma or ret_val==[]:
        #not comma = last processed was comma
        error_exit(f"could not parse declaration - {arg_list}",error_obj)
    return ret_val
    
#Display error, print partial output, exit
def error_exit(msg,error_obj):
    print("Error: "+msg)
    error_obj["output_f"].write("OUTPUT TERMINATED:\n")
    error_obj["output_f"].write("Error: "+msg+"\n")
    error_obj["output_f"].write(f"In file {error_obj['filename_list'][-1]}\n")
    exit(1)

#Expects one filename as input from command line
if len(argv)==1:
    print("Error: missing filename")
    exit(1)
elif len(argv)!=2:
    print("Usage: opt-mini.py filename")
    exit(1)

#Open processed.asm for combined output of all source files
try:
    output_f=open("processed.asm","wt")
except:
    print("Error: unable to open processed.asm for output")
    exit(1)
    
#Debug file to show where all global variables and functions are defined
try:
    debug_f=open("debug.txt","wt")
except:
    print("Error: unable to open debug.txt for output")
    exit(1)

#Variables
running=True                #Loop until reaches end of last source file
file_list=[]                #Stack of files included from source
filename_list=[argv[1]]     #List of filenames matching file_list for adding comments to combined source
file_name=argv[1]           #Filename to open - updated on each include statement in source
file_state="None"           #State machine state to track where in FUNC statement
global_dict={}              #Global variables defined outside of functions
func_name=""                #Name of function currently being processed
func_line_num=0             #Line number which the currently processed function starts on
func_temp=""                #Text of function. Formed in memory then written at end of function processing.
func_index=-1               #Index in final_text where variable definitions will be placed
func_dict={}                #All attributes of functions
args_dict={}                #Temp storage for args in func. Copied to func_dict for each function.
args_list=[]                #Temp storage for args in func. Copied to func_dict for each function.
vars_dict={}                #Temp storage for vars in func. Copied to func_dict for each function.
calls_list=[]               #Temp storage for call list in func. Copied to func_dict for each function.
file_output=""              #Text of final output file. Formed in memory then written to file at very end.
debug_output=[]             #List of lines to be added to debug file at very end.
error_obj={}                #Combination of information for passing errors messages then exiting
locals_begin=0              #Start of memory for local variables
locals_end=0xFF             #End of memory for local variables
debug_text_end=""           #Text to be added to end of debug file
final_text=[]               #List of source blocks and CALL statements filled in at end
assignments= ";Optimizer zero page assignments\n"   #List of zero page assignments made by optimizer
assignments+=";===============================\n"

#Constants
#=========
TYPE_TEXT=0                 #Constants for final_text - source text block
TYPE_CALL=1                 #Constants for final_text - call to be filled in
TYPE_VARS=2                 #Constants for final_text - function args and vars declaration

#Process file lines until last line of last included file
while running:
    #Try to open input file then any included file
    try:
        file_list+=[open(file_name,"rt")]
    except:
        error_exit(f"unable to open {file_name}",error_obj)
        
    #Process lines of  course
    while True:
        line=file_list[-1].readline()
        if line=="":
            #Done reading current file
            file_list.pop()
            if file_list==[]:
                #No more files to read! Stop looping.
                running=False
                break
            else:
                #Comment in source that end of included file reached
                file_output+=f";Done including {filename_list.pop()}\n"
        else:
            #Python does not always add a newline even when characters are read!
            #Strip off newline and add manually below since Python is not consistent
            if line[-1]=="\n": line=line[:-1]
            
            #Step through line character by character splitting into list of strings
            word=""
            line_objs=[]
            add_word=False
            next_word=""
            obj_state="None"
            for char in line.strip():
                if obj_state=="None":
                    if char in [" ","\t"]:
                        add_word=True
                        next_word=""
                    elif char==",":
                        add_word=True
                        next_word=","
                    elif char==";":
                        break
                    elif char=='"':
                        word+=char
                        obj_state="string"
                    elif char=="'":
                        word+=char
                        obj_state="char"
                    else:
                        word+=char
                elif obj_state=="string":
                    if char=='"':
                        obj_state="None"
                    word+=char
                elif obj_state=="char":
                    if char=='"':
                        obj_state="None"
                    word+=char
                if add_word:
                    if word!="":
                        line_objs+=[word]
                    if next_word==",":
                        line_objs+=[","]
                        word=""
                    else:
                        word=next_word
                    add_word=False
            if word!="":
                line_objs+=[word]
            
            #Examine first word of line of source to see how to handle it
            print_line=False
            first_word="" if len(line_objs)==0 else line_objs[0]
            #These words work the same in all modes
            if first_word in ["include","LOCALS_BEGIN","LOCALS_END"]:
                if len(line_objs)!=2:
                    error_exit(f"bad argument to {first_word} - {line.lstrip()}",error_obj)
            if first_word=="include":
                #Comment in source that file is being included
                final_text+=[[TYPE_TEXT,file_output]]
                file_output=""                
                debug_output+=[[len(final_text),f"include {line_objs[1]}",2]]
                file_output+=f"\n\n;Including {line_objs[1]}\n"
                file_name=line_objs[1]
                filename_list+=[file_name]
                break
            elif first_word=="CALL":
                #Only useful if within FUNC. No harm if outside of FUNC.
                if line_objs[1] not in calls_list:
                    calls_list+=[line_objs[1]]
                    
                #Make space in list of text objects for call to be filled in
                if file_state=="None":
                    final_text+=[[TYPE_TEXT,file_output]]
                    file_output=""
                else:
                    final_text+=[[TYPE_TEXT,func_temp]]
                    func_temp=""
                final_text+=[[TYPE_CALL,line+"\n",line_objs[:]]]
            elif first_word in ["LOCALS_BEGIN","LOCALS_END"]:
                num=line_objs[1]
                if num.isnumeric():
                    num=int(num)
                elif num[0]=="$" or num[:2]=="0x":
                    try:
                        num=int(num[1:],16) if num[0]=="$" else int(num[2:],16)
                    except:
                        error_exit(f"could not convert hex value for {first_word} - {num}",error_obj)
                else:
                    error_exit(f"invalid value for {first_word} - {num}",error_obj)
                if first_word=="LOCALS_BEGIN":
                    locals_begin=num
                else:
                    locals_end=num
            #These words depend on state machine state
            else:
                #Check argument counts regardless of input state machine
                if file_state in ["FUNC","ARGS","VARS"]:
                    if first_word in ["END"]:
                        if len(line_objs)!=1:
                            error_exit(f"bad argument to {first_word} - {line.lstrip()}",error_obj)
                                
                #State machine state None - top level before reaching a function
                if file_state=="None":
                    #Check argument counts
                    if first_word in ["FUNC","CALL"]:
                        if len(line_objs)==1:
                            error_exit(f"bad argument to {first_word} - {line.lstrip()}",error_obj)
                     
                    #Check for words that are invalud outside of function
                    if first_word in ["END","ARGS","VARS"]:
                        error_exit(f"{first_word} invalid outside of FUNC block - {line.lstrip()}",error_obj)
                     
                    #Handle special words the optimizer looks out for
                    if first_word in ["BYTE","WORD","STRING"]:
                        file_output+=f";{line}\n"
                        final_text+=[[TYPE_TEXT,file_output]]
                        file_output=""
                        padding=" "+line[:(len(line)-len(line.lstrip()))]
                        for i,arg in enumerate(arg_parse(line_objs,error_obj)):
                            file_output+=f"{padding}{arg}: DFS {1 if first_word=='BYTE' else 2}\n"
                            global_dict[arg]=first_word
                            debug_output+=[[len(final_text),f"GLOBAL {first_word} {arg}",i]]                           
                    elif first_word=="FUNC":
                        final_text+=[[TYPE_TEXT,file_output]]
                        debug_output+=[[len(final_text),f"FUNC {' '.join(line_objs[1:])}",0]]
                        file_output=f";{line}\n"
                        padding=" "+line[:(len(line)-len(line.lstrip()))]
                        file_output+=f"{padding}{line_objs[1]}:\n"
                        final_text+=[[TYPE_TEXT,file_output]]
                        file_output=""
                        func_temp=""
                        file_state="FUNC"
                        func_name=line_objs[1]
                        func_index=len(final_text)
                        final_text+=[[TYPE_VARS]]
                        args_dict={}
                        args_list=[]
                        vars_dict={}
                        calls_list=[]
                        vars_temp=""
                        func_begin=False
                        for attrib in line_objs[2:]:
                            if attrib=="BEGIN":
                                func_begin=True
                            else:
                                error_exit(f"unknown FUNC attribute {attrib} - {line.lstrip()}",error_obj)                        
                    elif first_word[:5]=="TODO:":
                        line=";"+line
                        print_line=True
                    else:
                        print_line=True
                #State machine state FUNC - inside a function but not in an ARGS or VARS block
                elif file_state=="FUNC":
                    if first_word in ["ARGS","VARS"]:
                        file_state=first_word
                    elif first_word=="END":
                        #END reached - output names assigned to local variables and text of function
                        func_dict[func_name]={}
                        func_dict[func_name]["ARGS"]=args_dict
                        func_dict[func_name]["ARGS LIST"]=args_list
                        func_dict[func_name]["VARS"]=vars_dict
                        func_dict[func_name]["CALLS"]=calls_list
                        func_dict[func_name]["BEGIN"]=func_begin
                        byte_total=0
                        debug_str="ARGS: "
                        for k,v in args_dict.items():
                            vars_temp+=f"{k} set _{func_name}.{k} ;ARG {v} {k}\n"
                            if debug_str!="ARGS: ": debug_str+=", "
                            debug_str+=f"{v} {k}"
                            if v in ["BYTE"]:
                                byte_total+=1
                            elif v in ["WORD","STRING"]:
                                byte_total+=2
                        if debug_str!="ARGS: ":
                            debug_output+=[[-1,debug_str,0]]
                        debug_str="VARS: "
                        for k,v in vars_dict.items():
                            vars_temp+=f"{k} set _{func_name}.{k} ;VAR {v} {k}\n"
                            if debug_str!="VARS: ": debug_str+=", "
                            debug_str+=f"{v} {k}"
                            if v in ["BYTE"]:
                                byte_total+=1
                            elif v in ["WORD","STRING"]:
                                byte_total+=2
                        if debug_str!="VARS: ":
                            debug_output+=[[-1,debug_str,0]]
                        if byte_total!=0:
                            debug_output+=[[-1,f"{byte_total} byte{'s' if byte_total>1 else ''} used",0]]
                        func_dict[func_name]["BYTES"]=byte_total
                        line_num=func_line_num+func_temp.count("\n")+2
                        func_temp+=f";{line}\n"
                        padding=" "+line[:(len(line)-len(line.lstrip()))]
                        func_temp+=padding+"RTS\n"
                        final_text+=[[TYPE_TEXT,func_temp]]
                        final_text[func_index]=[TYPE_VARS,vars_temp]
                        file_state="None"
                    elif first_word[:5]=="TODO:":
                        func_temp+=";"+line+"\n"
                    else:
                        func_temp+=line+"\n"
                #State machine state in ARGS or VARS block
                elif file_state in ["ARGS","VARS"]:
                    #Only variables declarations allowed in ARGS or VARS block
                    if first_word not in ["BYTE","WORD","STRING","END"]:
                        if not (file_state=="ARGS" and first_word=="VARS"):
                            error_exit(f"invalid in {file_state} block - {line.lstrip()}",error_obj)
                    
                    #Variable declarations
                    if first_word in ["BYTE","WORD","STRING"]:
                        for arg in arg_parse(line_objs,error_obj):    
                            if file_state=="ARGS":
                                args_dict[arg]=first_word
                                args_list+=[arg]
                            elif file_state=="VARS":
                                vars_dict[arg]=first_word
                    #End of ARGS or VARS block
                    elif first_word=="END":
                        file_state="FUNC"
            #No match to optimizer word above - output line to file        
            if print_line:
                file_output+=line+"\n"
                
        #Update info for error handling in case needed next iteration
        error_obj["output_f"]=output_f
        error_obj["filename_list"]=filename_list

#Assign zero page addresses to local variables
first_func=[k for k,v in func_dict.items() if v["BEGIN"]]
if len(first_func)==0:
    error_exit("no FUNC marked BEGIN found",error_obj)
elif len(first_func)>1:
    error_exit(f"multiple FUNCs marked BEGIN - {', '.join(first_func)}",error_obj)
first_func=first_func[0]
NAME=0
INDEX=1
BYTES=2
func_nodes=[[first_func,0]]
byte_total=0
address_max={}
while True:
    node=func_nodes[-1]
    if node[INDEX]>=len(func_dict[node[NAME]]["CALLS"]):
        #Done with child node - remove from stack
        byte_total=0
        for node in func_nodes:
            byte_total+=func_dict[node[NAME]]["BYTES"]
        byte_total-=func_dict[node[NAME]]["BYTES"]  #Readjust since last node bytes should not count
        if node[NAME] not in address_max or address_max[node[NAME]]<byte_total:
            address_max[node[NAME]]=byte_total
        func_nodes.pop()        
        if func_nodes==[]:
            #No more nodes left to check - done
            break
        func_nodes[-1][INDEX]+=1
    else:
        #New child node added to stack
        func_nodes+=[[func_dict[node[NAME]]["CALLS"][node[INDEX]],0]]
        byte_total=0
        debug_line=""
        for node in func_nodes:
            if debug_line!="":
                debug_line+=" > "
            debug_line+=f'{node[NAME]}({func_dict[node[NAME]]["BYTES"]})'
            byte_total+=func_dict[node[NAME]]["BYTES"]
        byte_total-=func_dict[node[NAME]]["BYTES"]  #Readjust since last node bytes should not count
        debug_text_end+=f'{debug_line} - ({byte_total} bytes)\n'
name_list=list(address_max.keys())
name_list.sort()
MAX_LINE_LEN=40
for name in name_list:
    base_address=address_max[name]
    #Arguments
    arg_list=list(func_dict[name]["ARGS"].keys())
    arg_list.sort()
    for arg in arg_list:
        arg_type=func_dict[name]["ARGS"][arg]
        addition=f"_{name}.{arg} equ ${(hex(base_address)[2:]).upper()}"
        padding=max(1,MAX_LINE_LEN-len(addition))*" "
        assignments+=f"{addition}{padding};ARG {arg_type}\n"
        if arg_type in ["BYTE"]:
            base_address+=1
        elif arg_type in ["WORD","STRING"]:
            base_address+=2
    #Local variables
    var_list=list(func_dict[name]["VARS"].keys())
    var_list.sort()
    for var in var_list:
        var_type=func_dict[name]["VARS"][var]
        addition=f"{name}.{var} equ ${(hex(base_address)[2:]).upper()}"
        padding=max(1,MAX_LINE_LEN-len(addition))*" "
        assignments+=f"_{addition}{padding};VAR {var_type}\n"
        if var_type in ["BYTE"]:
            base_address+=1
        elif var_type in ["WORD","STRING"]:
            base_address+=2
assignments+="\n"

#Write optimizer assigned zero page addresses output file followed by chunks of source code
output_f.write(assignments)
final_text+=[[TYPE_TEXT,file_output]]

for i in final_text:       
    if i[0]==TYPE_TEXT:
        output_f.write(i[1])
    elif i[0]==TYPE_VARS:
        if len(i)==1:
            error_exit("VAR block not filled in! FUNC without END?",error_obj)
        output_f.write(i[1])
    elif i[0]==TYPE_CALL:
        #Formulate CALL statement - do here at end after all functions read in
        func=i[2][1]
        func_args=func_dict[func]["ARGS"]
        func_args_list=func_dict[func]["ARGS LIST"]
        call_args=i[2][2:]
        
        print(i[1].lstrip(),end="")
        print(f"\t{str(i[2])}")
        print(f"\t{call_args}")
        print(f"\t{func_args}")
        print(f"\t{func_args_list}")
        
        comma=True
        comma_found=False
        call_text=""
        index=0
        for call_arg in call_args:
            if comma==False:
                if arg==",":
                    error_exit(f"comma not expected in CALL - {i[1].lstrip()}",error_obj)
                else:
                    #Valid input - copy to destination
                    if index>=len(func_args_list):
                        error_exit(f"too many arguments in CALL - {i[1].lstrip()}",error_obj)
                    func_arg_name=func_args_list[index]
                    index+=1
                    func_arg_type=func_args[func_arg_name]
                    if func_arg_type in ["BYTE"]:
                        call_text+=f"\tLDA {call_arg}\n"
                        call_text+=f"\tSTA _{func}.{func_arg_name}\n"
                    elif func_arg_type in ["WORD"]:
                        call_text+=f"\tLDA {call_arg}#256\n"
                        call_text+=f"\tSTA _{func}.{func_arg_name}\n"
                        call_text+=f"\tLDA {call_arg}>>8\n"
                        call_text+=f"\tSTA _{func}.{func_arg_name}+1\n"
                    elif func_arg_type in ["STRING"]:
                        pass
                        
            else:
                if call_arg!=",":
                    error_exit(f"comma expected but found '{call_arg}' in CALL - {i[1].lstrip()}",error_obj)
                comma_found=True
            comma=not comma
        if comma==False:
            error_exit(f"missing value in CALL - {i[1].lstrip()}",error_obj)
        call_text+=f"\tJSR {func}\n"
        
        print(call_text)
        #output_f.write(i[1])        

#Adjust line numbers for debug file output based on length of assignments block and output to file
debug_f.write("1: Zero page assignments\n")
assignments_len=assignments.count("\n")
block_lens=[]
total_len=assignments_len+1
for block in final_text:
    block_lens+=[total_len]
    total_len+=block[1].count("\n")
for line in debug_output:
    line_num=block_lens[line[0]]+line[2]
    if line[0]==-1:
        debug_f.write(" "*len(str(line_num))+"  ")
    else:
        debug_f.write(f"{line_num}: ")
    debug_f.write(line[1]+"\n")
debug_f.write("\n")
    
#Also add call graph to debug file
debug_f.write(debug_text_end)

#Close output and debug files
output_f.close()
debug_f.close()
