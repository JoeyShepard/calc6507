#!/usr/bin/env python3

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
running=True                        #Loop until reaches end of last source file
file_list=[]                        #Stack of files included from source
filename_list=[argv[1]]             #List of filenames matching file_list for adding comments to combined source
file_name=argv[1]                   #Filename to open - updated on each include statement in source
file_state="None"                   #State machine state to track where in FUNC statement
global_dict={}                      #Global variables defined outside of functions
func_name=""                        #Name of function currently being processed
func_line_num=0                     #Line number which the currently processed function starts on
func_temp=""                        #Text of function. Formed in memory then written at end of function processing.
func_index=-1                       #Index in final_text where variable definitions will be placed
func_dict={}                        #All attributes of functions
args_dict={}                        #Temp storage for args in func. Copied to func_dict for each function.
args_list=[]                        #Temp storage for args in func. Copied to func_dict for each function.
vars_dict={}                        #Temp storage for vars in func. Copied to func_dict for each function.
calls_list=[]                       #Temp storage for call list in func. Copied to func_dict for each function.
file_output=""                      #Text of final output file. Formed in memory then written to file at very end.
debug_output=[]                     #List of lines to be added to debug file at very end.
error_obj={}                        #Combination of information for passing errors messages then exiting
locals_begin=0                      #Start of memory for local variables
locals_end=0xFF                     #End of memory for local variables
debug_text_end=""                   #Text to be added to end of debug file
final_text=[]                       #List of source blocks and CALL statements filled in at end
string_assignments=""               #Assignment of string literals from CALL
string_assignments_written=False    #Whether string literals from CALL written to combined source
string_index=1                      #ID number assigned for string literals from CALL
func_name_inserted=False            #Whether label for FUNC name has been inserted into text
assignments=[]                      #List of zero page assignments made by optimizer
regs_counter=0                      #Counter for floating point registers reused for temp mem


#Constants
#=========
TYPE_TEXT=0                 #Constants for final_text - source text block
TYPE_CALL=1                 #Constants for final_text - call to be filled in
TYPE_VARS=2                 #Constants for final_text - function args and vars declaration
TYPE_STRINGS=3              #Constants for final_text - string literals from CALL

#Process file lines until last line of last included file
while running:
    #Try to open input file then any included file
    try:
        file_list+=[open(file_name,"rt")]
    except:
        error_exit(f"unable to open {file_name}",error_obj)
        
    #Process lines of source
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
            elif first_word[:5] in ["TODO:","DONE:"]:
                line=";"+line
                print_line=True
            elif first_word=="CALL":
                #Only useful if within FUNC. No harm if outside of FUNC.
                if line_objs[1] not in calls_list:
                    calls_list+=[line_objs[1]]
                    
                #Make space in list of text objects for call to be filled in
                if file_state=="None":
                    final_text+=[[TYPE_TEXT,file_output]]
                    file_output=""
                else:
                    if func_name_inserted==False:
                        func_temp+=f"\t{func_name}:\n"
                        func_name_inserted=True
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
                if file_state in ["FUNC","ARGS","VARS","REGS"]:
                    if first_word in ["END"]:
                        if len(line_objs)!=1:
                            error_exit(f"bad argument to {first_word} - {line.lstrip()}",error_obj)
                                
                #State machine state None - top level before reaching a function
                if file_state=="None":
                    #Check argument counts
                    if first_word in ["FUNC","CALL"]:
                        if len(line_objs)==1:
                            error_exit(f"bad argument to {first_word} - {line.lstrip()}",error_obj)
                     
                    #Check for words that are invalid outside of function
                    if first_word in ["END","ARGS","VARS"]:
                        error_exit(f"{first_word} invalid outside of FUNC block - {line.lstrip()}",error_obj)
                     
                    #Check for words that should have no arguments
                    if first_word in ["STRING_LITERALS","REGS"]:
                        if len(line_objs)!=1:
                            error_exit(f"{first_word} does not take arguments - {line.lstrip()}",error_obj)
                     
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
                        
                        #Local labels use last defined symbol, so func label comes after all variables
                        #padding=" "+line[:(len(line)-len(line.lstrip()))]
                        #file_output+=f"{padding}{line_objs[1]}:\n"
                        
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
                        func_name_inserted=False
                        for attrib in line_objs[2:]:
                            if attrib=="BEGIN":
                                func_begin=True
                            else:
                                error_exit(f"unknown FUNC attribute {attrib} - {line.lstrip()}",error_obj)                        
                    elif first_word=="STRING_LITERALS":
                        final_text+=[[TYPE_TEXT,file_output]]
                        file_output=""
                        final_text+=[[TYPE_STRINGS]]
                    elif first_word=="REGS":
                        file_state="REGS"
                        regs_counter=0
                    else:
                        print_line=True
                #State machine state FUNC - inside a function but not in an ARGS or VARS block
                elif file_state=="FUNC":
                    if first_word in ["ARGS","VARS"]:
                        file_state=first_word
                    elif first_word=="REGS":
                        error_exit("REGS not allowed inside FUNC block",error_obj)
                    elif first_word=="END":
                        #END reached - output names assigned to local variables and text of function
                        func_dict[func_name]={}
                        func_dict[func_name]["ARGS"]=args_dict
                        func_dict[func_name]["ARGS LIST"]=args_list
                        func_dict[func_name]["VARS"]=vars_dict
                        func_dict[func_name]["CALLS"]=calls_list
                        func_dict[func_name]["BEGIN"]=func_begin
                        func_dict[func_name]["TOUCHES"]=set()
                        byte_total=0
                        
                        #Insert ARGS definitions before function begin
                        debug_str="ARGS: "
                        for k,v in args_dict.items():
                            vars_temp+=f"\tset {k}, _{func_name}.{k} ;ARG {v} {k}\n"
                            if debug_str!="ARGS: ": debug_str+=", "
                            debug_str+=f"{v} {k}"
                            if v in ["BYTE"]:
                                byte_total+=1
                            elif v in ["WORD","STRING"]:
                                byte_total+=2
                        if debug_str!="ARGS: ":
                            debug_output+=[[-1,debug_str,0]]

                        #Insert VARS definitions before function begin
                        debug_str="VARS: "
                        for k,v in vars_dict.items():
                            vars_temp+=f"\tset {k}, _{func_name}.{k} ;VAR {v} {k}\n"
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
                        if func_name_inserted==False:
                            func_temp+=f"\t{func_name}:\n"
                            func_name_inserted=True
                        func_temp+=f";{line}\n"
                        padding=" "+line[:(len(line)-len(line.lstrip()))]
                        func_temp+=padding+"RTS\n"
                        final_text+=[[TYPE_TEXT,func_temp]]
                        final_text[func_index]=[TYPE_VARS,vars_temp]
                        file_state="None"
                    else:
                        if func_name_inserted==False:
                            func_temp+=f"\t{func_name}:\n"
                            func_name_inserted=True
                        func_temp+=line+"\n"

                #State machine state in ARGS or VARS block
                elif file_state in ["ARGS","VARS"]:
                    #Only variable declarations allowed in ARGS or VARS block
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

                #State machine state in REGS block
                elif file_state=="REGS":
                    #Only register variable declarations allowed in REGS block
                    if first_word not in ["BYTE","WORD","END"]: 
                        error_exit(f"invalid in {file_state} block - {line.lstrip()}",error_obj)

                    #Register variable declarations
                    if first_word in ["BYTE","WORD"]:
                        for arg in arg_parse(line_objs,error_obj):    
                            file_output+=f"\tset {arg}, (R{int(regs_counter/8)}+{regs_counter%8}) ;REGS {first_word} {arg}\n"
                            if first_word=="BYTE":
                                regs_counter+=1
                            elif first_word=="WORD":
                                regs_counter+=2

                    #End of REGS block
                    elif first_word=="END":
                        file_state="None"

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
func_used_list=[first_func]
while True:
    node=func_nodes[-1]
    if node[INDEX]>=len(func_dict[node[NAME]]["CALLS"]):
        #Done with child node - remove from stack
        func_nodes.pop()        
        if func_nodes==[]:
            #No more nodes left to check - done
            break
        func_nodes[-1][INDEX]+=1
    else:
        #New child node added to stack
        if func_dict[node[NAME]]["CALLS"][node[INDEX]] not in func_used_list:
            func_used_list+=[func_dict[node[NAME]]["CALLS"][node[INDEX]]]
        func_nodes+=[[func_dict[node[NAME]]["CALLS"][node[INDEX]],0]]
        byte_total=0
        debug_line=""
        all_funcs=[node_info[NAME] for node_info in func_nodes]
        for node_info in func_nodes:
            #Record what nodes each node touches
            func_dict[node_info[NAME]]["TOUCHES"].update(all_funcs)
            #Debug info
            if debug_line!="":
                debug_line+=" > "
            debug_line+=f'{node_info[NAME]}({func_dict[node_info[NAME]]["BYTES"]})'
            byte_total+=func_dict[node_info[NAME]]["BYTES"]
        debug_text_end+=f'{debug_line} - ({byte_total} bytes)\n'

assigned_mem=[[] for i in range(locals_end-locals_begin)]
func_used_list.sort()
for func in func_used_list:
    #Loop through arguments then local variables
    func_touched_list=func_dict[func]["TOUCHES"]
    for var_arg in ["ARGS","VARS"]:
        var_list=list(func_dict[func][var_arg].keys())
        var_list.sort()
        for var in var_list:
            var_type=func_dict[func][var_arg][var]
            for address in range(len(assigned_mem)):
                for address_func in assigned_mem[address]:
                    if address_func in func_touched_list:
                        #Memory address already assigned to function that touches current function - skip address
                        break
                else:
                    #For loop completed - no clashes
                    if var_type in ["BYTE"]:
                        #Only one byte needed - assign memory
                        assignments+=[[f"_{func}.{var}",locals_begin+address,f";{'VAR' if var_arg=='VARS' else 'ARG'} {var_type}",(func,var,var_type)]]
                        assigned_mem[address]+=[func]
                        #Skip to next var to assign
                        break 
                    elif var_type in["WORD","STRING"]:
                        #Two bytes needed - check that next byte is free too before assigning memory
                        if address+1>=len(assigned_mem):
                            error_exit(f"end of locals memory reached but couldn't assign {var_type} {var} in {var_arg} of {func}",error_obj)
                        for address_func in assigned_mem[address+1]:
                            if address_func in func_touched_list:
                               #Memory address already assigned to function that touches current function - skip address
                                break
                        else:
                            #For loop completed for two-byte var - no clashes
                            assignments+=[[f"_{func}.{var}",locals_begin+address,f";{'VAR' if var_arg=='VARS' else 'ARG'} {var_type}",(func,var,var_type)]]
                            assigned_mem[address]+=[func]
                            assigned_mem[address+1]+=[func]
                            #Skip to next var to assign
                            break 
            else:
                error_exit(f"end of locals memory reached but couldn't assign {var_type} {var} in {var_arg} of {func}",error_obj)
            
#Output debug html file
assignment_debug=[[] for _ in range(locals_end-locals_begin)]
for assignment in assignments:
    _,address,_,debug_info=assignment
    assignment_debug[address-locals_begin]+=[debug_info]
    func,var,var_type=debug_info
    if var_type in ["WORD","STRING"]:
        assignment_debug[address-locals_begin+1]+=[debug_info]
with open("debug.html","w") as fptr:
    fptr.write('<html><body>\n<h1>Zero page assignments</h1>\n')
    fptr.write('<table border="1">\n')
    for index in range(len(assignment_debug)):
        fptr.write(f"<tr>\n<td>0x{hex(index+locals_begin)[2:]}</td>\n")
        for assignment in assignment_debug[index]:
            func,var,var_type=assignment
            fptr.write(f"<td>{var_type} {func}.{var}</td>\n")
        fptr.write("</tr\n\n>")
    fptr.write("</table></body></html>\n")

#Write optimizer assigned zero page addresses to output file
output_f.write(";Optimizer zero page assignments\n")
output_f.write(";===============================\n")
assignment_length=0
func_unused_list=[name for name in func_dict.keys() if name not in func_used_list]
func_unused_list.sort()
for assignment in assignments:
    name,_,_,_=assignment
    assignment_length=max(assignment_length, len(name))
for name in func_unused_list:
    for var in func_dict[name]["VARS"]:
        assignment_length=max(assignment_length, len(f"_{name}.{var}"))
    for arg in func_dict[name]["ARGS"]:
        assignment_length=max(assignment_length, len(f"_{name}.{arg}"))
for assignment in assignments:
    name,address,var_type,_=assignment
    address="$"+(("00"+(hex(address).upper()[2:]))[-2:])
    output_f.write(f'{name}{" "*(assignment_length-len(name))} equ {address}   {var_type}\n')
output_f.write("\n")

#Write dummy addresses for functions not appearing in call graph
for name in func_unused_list:
    for var in func_dict[name]["VARS"]:
        var_type=func_dict[name]["VARS"][var]
        var_name=f"_{name}.{var}"
        output_f.write(f'{var_name}{" "*(assignment_length-len(var_name))} equ dummy ;VAR {var_type}\n')
    for arg in func_dict[name]["ARGS"]:
        arg_type=func_dict[name]["ARGS"][arg]
        arg_name=f"_{name}.{arg}"
        output_f.write(f'{arg_name}{" "*(assignment_length-len(arg_name))} equ dummy ;ARG {arg_type}\n')
output_f.write("\n")

#Write source code pieces to output file
final_text+=[[TYPE_TEXT,file_output]]
for i,text_block in enumerate(final_text):
    if text_block[0]==TYPE_TEXT:
        output_f.write(text_block[1])
    elif text_block[0]==TYPE_VARS:
        if len(text_block)==1:
            error_exit("VAR block not filled in! FUNC without END?",error_obj)
        output_f.write(text_block[1])
    elif text_block[0]==TYPE_STRINGS:
        output_f.write(string_assignments)
        string_assignments_written=True
    elif text_block[0]==TYPE_CALL:
        #Formulate CALL statement - do here at end after all functions read in
        func=text_block[2][1]
        func_args=func_dict[func]["ARGS"]
        func_args_list=func_dict[func]["ARGS LIST"]
        call_args=text_block[2][2:]
        comma=True
        comma_found=False
        index=0
        func_comment=text_block[1].lstrip().replace('\n','')
        call_text=f"\t;{func_comment}\n"
        for call_arg in call_args:
            if comma==False:
                if arg==",":
                    error_exit(f"comma not expected in CALL - {text_block[1].lstrip()}",error_obj)
                else:
                    #Valid input - copy to destination
                    if index>=len(func_args_list):
                        error_exit(f"too many arguments in CALL - {text_block[1].lstrip()}",error_obj)
                    func_arg_name=func_args_list[index]
                    index+=1
                    func_arg_type=func_args[func_arg_name]
                    if func_arg_type in ["BYTE"]:
                        if call_arg[0]=="#":
                            #Immediate
                            call_text+=f"\tLDA #({call_arg[1:]})#256\n"
                            call_text+=f"\tSTA _{func}.{func_arg_name}\n"
                        else:
                            #Address
                            call_text+=f"\tLDA {call_arg}\n"
                            call_text+=f"\tSTA _{func}.{func_arg_name}\n"
                    elif func_arg_type in ["WORD"]:
                        if call_arg[0]=="#":
                            #Immediate
                            call_text+=f"\tLDA #({call_arg[1:]})#256\n"
                            call_text+=f"\tSTA _{func}.{func_arg_name}\n"
                            call_text+=f"\tLDA #({call_arg[1:]})>>8\n"
                            call_text+=f"\tSTA _{func}.{func_arg_name}+1\n"
                        else:
                            #Address
                            call_text+=f"\tLDA {call_arg}\n"
                            call_text+=f"\tSTA _{func}.{func_arg_name}\n"
                            call_text+=f"\tLDA ({call_arg})+1\n"
                            call_text+=f"\tSTA _{func}.{func_arg_name}+1\n"
                    elif func_arg_type in ["STRING"]:
                        if call_arg[0]=='"':
                            #String literal
                            if call_arg[-1]!='"':
                                error_exit(f'unrecognized argument in CALL beginning with " - {call_arg.lstrip()}',error_obj)
                            if string_assignments_written:
                                error_exit('CALL with string literal after list of literals added to source. Move STRING_LITERALS below last CALL.')
                            string_address=f"_string_literal{('00000'+str(string_index))[-5:]}"
                            string_assignments+=f"\t{string_address}: FCB {call_arg},0\n"
                            string_index+=1
                            call_text+=f"\tLDA #({string_address})#256\n"
                            call_text+=f"\tSTA _{func}.{func_arg_name}\n"
                            call_text+=f"\tLDA #({string_address})>>8\n"
                            call_text+=f"\tSTA _{func}.{func_arg_name}+1\n"

                        else:
                            #String address
                            string_address=call_arg
                            call_text+=f"\tLDA {string_address}\n"
                            call_text+=f"\tSTA _{func}.{func_arg_name}\n"
                            call_text+=f"\tLDA ({string_address})+1\n"
                            call_text+=f"\tSTA _{func}.{func_arg_name}+1\n"
            else:
                if call_arg!=",":
                    error_exit(f"comma expected but found '{call_arg}' in CALL - {text_block[1].lstrip()}",error_obj)
                comma_found=True
            comma=not comma
        if comma==False:
            error_exit(f"missing value in CALL - {text_block[1].lstrip()}",error_obj)
        call_text+=f"\tJSR {func}\n\n"
        #Replace TYPE_CALL block in final_text with generated text
        final_text[i]=[TYPE_TEXT,call_text]
        output_f.write(call_text)        

#Make sure string literals from CALL were written
if string_assignments_written==False:
    error_exit("string literals from CALL not written. STRING_LITERALS appears in source?",error_obj)

#Output debug file
debug_f.write("Line numbers\n")
debug_f.write("============\n")
debug_f.write("1: Zero page assignments\n")
assignments_len=assignments.count("\n")
block_lens=[]
total_len=assignments_len+1
for block in final_text:
    block_lens+=[total_len]
    if block[0]==TYPE_STRINGS:
        total_len+=string_assignments.count("\n")
        string_assignments_written=True
    else:
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
debug_f.write("Call graph\n")
debug_f.write("==========\n")
debug_f.write(debug_text_end)
debug_f.write("\n")

#Add functions not appearing in call graph to debug file
debug_f.write("Functions outside of call graph\n")
debug_f.write("===============================\n")
for name in func_unused_list:
    debug_f.write(f'{name}({func_dict[name]["BYTES"]} bytes)\n')
debug_f.write("\n")

#String literals from CALL
debug_f.write("String literals from CALL\n")
debug_f.write("=========================\n")
for assignment in string_assignments.split("\n"):
    debug_f.write(assignment.lstrip()+"\n")
debug_f.write("\n")

#Close output and debug files
output_f.close()
debug_f.close()
