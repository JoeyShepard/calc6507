import os,sys

#Constants
#=========
STATE_GLOBAL=0
STATE_LOCAL=1
STATE_COMMENT=2
STATE_TYPES=3
STATE_DESCRIPTION=4
STATE_EXAMPLE=5
STATE_SEE_ALSO=6
STATE_SYMBOL=7
STATE_BLOCK=8
STATE_LIST=9

PIC_PATH="../images/resized/"
HTML_PATH="./generated/"

TYPE_FLOAT='<span class="word_type_generic {}">float</span>'
TYPE_RAW_HEX='<span class="word_type_generic {}">raw hex</span>'
TYPE_SMART_HEX='<span class="word_type_generic {}">smart hex</span>'
TYPE_STRING='<span class="word_type_generic {}">string</span>'
TYPE_ARG='<span class="word_type_arg">{}</span>'
TYPE_NOTE='<span class="word_type_note">{}</span>'

SEE_ALSO_LINK='<a href="'+HTML_PATH+'{}.html">{}</a>'


#Functions
#=========

def print_error(error_msg,line_num):
    print("Error:",error_msg,"Line:",line_num)

def len_check(line,length,line_num):
    if len(line)<length:
        print_error(f'Expected {length-1} arguments but found {" ".join(line)}.',line_num)
        return False
    else:
        return True

def gen_pages():

    #Initialize variables
    running=True
    reset_word=True
    output_html=False
    
    processed_words={}
    expected_words=[]

    state=STATE_GLOBAL

    global_objs={}
   
    #Clear output directory
    os.system("del generated\\* /Q")
    os.system("copy templates\\words.css generated\\words.css")

    #Regenerate image files
    os.system("images\\resize.bat")

    #Read in word HTML template
    f=open("templates/word_template.html")
    template_word=f.readlines()
    f.close()
            
    #Process markup file
    f=open("words.txt")
    file_line_num=0
    while running:

        #Reset values for current word if necessary
        if reset_word:
            word_name=""
            word_show=""
            word_comment=""
            word_types=""
            word_description=""
            word_example=""
            word_see_also=""
            word_type_float="word_type_disabled"
            word_type_raw_hex="word_type_disabled"
            word_type_smart_hex="word_type_disabled"
            word_type_string="word_type_disabled"
            word_type_name=""
            word_type_name_list=""
            word_type_note=""
            word_type_none=False
            word_see_also_none=True
            symbol_name=""
            symbol_content=""
            local_objs={}
            state=STATE_GLOBAL
            reset_word=False

        #Read line from file
        file_line=f.readline()
        file_line_num+=1
        if not file_line:
            output_html=True
            running=False
        line=[]

        #Filter out comments and do replacements
        for i in file_line.split():
            if i[0]=="#":
                break
            else:
                if i[0]=="%":
                    if i[1:] in local_objs.keys():
                        i=local_objs[i[1:]]
                    elif i[1:] in global_objs.keys():
                        i=global_objs[i[1:]]
                    else:
                        print_error("Replacement symbol "+i+" not found.",file_line_num)
                        running=False
                line+=[i]
                    
        #Skip empty lines
        if line==[]:
            continue

        #State machine
        if state==STATE_GLOBAL:
            if line[0]=="WORD":
                running=len_check(line,2,file_line_num)
                if line[1] not in expected_words:
                    print_error("Word not in expected list:"+line[1]+".",file_line_num)
                    running=False
                if running:
                    word_name=line[1]
                    word_show=word_name
                    state=STATE_LOCAL
            elif line[0]=="SYMBOL":
                running=len_check(line,2,file_line_num)
                if running:
                    symbol_name=line[1]
                    symbol_content=""
                    state=STATE_SYMBOL
            elif line[0]=="BLOCK":
                running=len_check(line,2,file_line_num)
                if running:
                    symbol_name=line[1]
                    symbol_content=""
                    state=STATE_BLOCK
            elif line[0]=="PIC":
                running=len_check(line,3,file_line_num)
                if running:
                    temp_obj='<img src="'+PIC_PATH+line[2]+'">'
                    if len(line)>3:
                        temp_obj='<figure class="word_img_figure">'+temp_obj+'<figcaption class="word_img_caption">'
                        temp_obj+=" ".join(line[3:])+"</figcaption></figure>"
                    global_objs[line[1]]=temp_obj      
            elif line[0]=="LIST":
                state=STATE_LIST   
            else:
                print_error("Unknown symbol in global scope: "+line[0]+".",file_line_num)
                running=False
        elif state==STATE_LOCAL:
            if line[0]=="SHOW":
                running=len_check(line,2,file_line_num)
                if running:
                    word_show=line[1]
            elif line[0]=="PIC":
                running=len_check(line,3,file_line_num)
                if running:
                    temp_obj='<img src="'+PIC_PATH+line[2]+'">'
                    if len(line)>3:
                        temp_obj='<figure class="word_img_figure">'+temp_obj+'<figcaption class="word_img_caption">'
                        temp_obj+=" ".join(line[3:])+"</figcaption></figure>"
                    local_objs[line[1]]=temp_obj
            elif line[0]=="COMMENT":
                state=STATE_COMMENT
            elif line[0]=="TYPES":
                state=STATE_TYPES
            elif line[0]=="DESCRIPTION":
                state=STATE_DESCRIPTION
            elif line[0]=="EXAMPLE":
                state=STATE_EXAMPLE
            elif line[:2]==["SEE","ALSO"]:
                state=STATE_SEE_ALSO
            elif line[0]=="END":

                gen_html=""
                skip_line=False
                for template_line in template_word:
                    
                    if skip_line:
                        if template_line.strip()=="%word_type_end":
                            skip_line=False
                        elif template_line.strip()=="%word_see_also_end":
                            skip_line=False
                    else:                              
                        if template_line.strip()=="%word_show":
                            gen_html+="\t\t\t"+word_show+"\n"
                        elif template_line.strip()=="%word_comment":
                            gen_html+=f"\t\t\t"+word_comment+"\n"
                        elif template_line.strip()=="%word_type_begin":
                            if word_type_none:
                                skip_line=True
                        elif template_line.strip()=="%word_type_args":
                            gen_html+=word_type_name_list+"\n"
                        elif template_line.strip()=="%word_types":
                            gen_html+=word_types+"\n"
                        elif template_line.strip()=="%word_type_end":
                            #signal to stop filtering though not filtering if reach here
                            pass
                        elif template_line.strip()=="%word_type_note":
                            gen_html+=word_type_note+"\n"
                        elif template_line.strip()=="%word_description":
                            gen_html+=word_description+"\n"
                        elif template_line.strip()=="%word_example":
                            gen_html+=word_example+"\n"
                        elif template_line.strip()=="%word_see_also_begin":
                            if word_see_also_none:
                                skip_line=True
                        elif template_line.strip()=="%word_see_also":
                            gen_html+=word_see_also+"\n"
                        elif template_line.strip()=="%word_see_also_end":
                            #signal to stop filtering though not filtering if reach here
                            pass
                        else:
                            gen_html+=template_line
                            
                processed_words[word_name]=gen_html
                
                reset_word=True
                
        elif state==STATE_COMMENT:
            if line[0]=="END":
                state=STATE_LOCAL
            else:
                word_comment=" ".join(line)
        elif state==STATE_TYPES:
            if line[0]=="END" or line[0]=="ARG":
                if word_type_name!="":
                    if word_types!="":
                        word_types+="<br>\n\n"
                    word_types+="-"
                    word_types+=("\t\t\t\t\t"+TYPE_FLOAT+"\n").format(word_type_float)
                    word_types+=("\t\t\t\t\t"+TYPE_RAW_HEX+"\n").format(word_type_raw_hex)
                    word_types+=("\t\t\t\t\t"+TYPE_SMART_HEX+"\n").format(word_type_smart_hex)
                    word_types+=("\t\t\t\t\t"+TYPE_STRING).format(word_type_string)

                    if word_type_name_list!="":
                        word_type_name_list+="<br>\n"
                    word_type_name_list+=("\t\t\t\t\t"+TYPE_ARG).format(word_type_name)
                    
                if line[0]=="END":
                    state=STATE_LOCAL
                elif line[0]=="ARG":
                    running=len_check(line,2,file_line_num)
                    if running:
                        word_type_float="word_type_disabled"
                        word_type_raw_hex="word_type_disabled"
                        word_type_smart_hex="word_type_disabled"
                        word_type_string="word_type_disabled"
                        word_type_name=line[1]
                        word_type_note=""
                        word_type_none=False
            elif line[0]=="NONE":
                word_type_none=True
                pass
            elif line[0]=="ANY":
                word_type_float="word_type_float"
                word_type_raw_hex="word_type_raw_hex"
                word_type_smart_hex="word_type_smart_hex"
                word_type_string="word_type_string"
            elif line[0]=="FLOAT":
                word_type_float="word_type_float"
            elif line[0]=="RAW_HEX":
                word_type_raw_hex="word_type_raw_hex"
            elif line[0]=="SMART_HEX":
                word_type_smart_hex="word_type_smart_hex"
            elif line[0]=="STRING":
                word_type_string="word_type_string"
            elif line[0]=="NOTE":
                running=len_check(line,2,file_line_num)
                if running:
                    word_type_note="\t\t\t\t"+TYPE_ARG.format(" ".join(line[1:]))
            else:
                print_error("Unknown type: "+line[0]+".",file_line_num)
                running=False
        elif state==STATE_DESCRIPTION:
            if line[0]=="END":
                state=STATE_LOCAL
            else:
                if word_description!="":
                    word_description+="\n"
                word_description+='\t\t\t<p class="word_description_p">'+" ".join(line)+"</p>"
        elif state==STATE_EXAMPLE:
            if line[0]=="END":
                state=STATE_LOCAL
            else:
                if word_example!="":
                    word_example+="<br>\n"
                word_example+="\t\t\t"+" ".join(line)
        elif state==STATE_SEE_ALSO:
            if line[0]=="END":
                state=STATE_LOCAL
            else:
                if line[0] not in expected_words:
                    print_error("Word not found in expected words: "+line[0]+".",file_line_num)
                    running=False
                if running:
                    if word_see_also!="":
                        word_see_also+="\n"
                    if len(line)==1:
                        word_see_also+="\t\t\t"+SEE_ALSO_LINK.format(line[0],line[0])
                    else:
                        word_see_also+="\t\t\t"+SEE_ALSO_LINK.format(line[0],line[1])
                    word_see_also_none=False
        elif state==STATE_SYMBOL:
            if line[0]=="END":
                local_objs[symbol_name]=symbol_content
                state=STATE_GLOBAL
            else:
                if symbol_content!="":
                    symbol_content+="<br>\n\t\t\t"
                symbol_content+=" ".join(line)
        elif state==STATE_BLOCK:
            if line[0]=="END":
                local_objs[symbol_name]=symbol_content
                state=STATE_GLOBAL
            else:
                if symbol_content!="":
                    symbol_content+="\n\t\t\t"
                symbol_content+="<p>"+" ".join(line)+"</p>"
        elif state==STATE_LIST:
            if line[0]=="END":
                state=STATE_GLOBAL
            elif line[0] in expected_words:
                print_error("Word found twice in list of expected words: "+line[0]+".", file_line_num)
                running=False
            else:
                expected_words+=[line[0]]
                
    f.close()

    #Output generated html to files if finished without error
    if output_html:

        #Read in body HTML template
        template_body_head=""
        template_body_tail=""
        f=open("templates/body_template.html")
        processing_head=True
        for line in f:
            if processing_head:
                if line.strip()=="%word":
                    processing_head=False
                else:
                    template_body_head+=line
            else:
                template_body_tail+=line
        
        #Check for missing definitions before outputting html
        missing_words=[]
        for word in expected_words:
            if word not in processed_words.keys():
                missing_words+=[word]
                
        if missing_words!=[]:
            print("\nError: Definition missing for "+str(len(missing_words))+" of "+str(len(expected_words))+" expected words: ")
            print(*missing_words,sep=", ")

        #Output html to individual files and to one collected file
        combined_file=open(HTML_PATH+"ALL.html","wt")
        combined_file.write(template_body_head)
        for k,v in processed_words.items():
            gen_file=open(HTML_PATH+k+".html","wt")
            gen_file.write(template_body_head)
            gen_file.write(v)
            gen_file.write(template_body_tail)
            gen_file.close()

            combined_file.write(f"\t\t<!--{k}-->\n")
            combined_file.write(v)
            combined_file.write("<br><br><br>\n\n")

        combined_file.write(template_body_tail)
        combined_file.close()
        
        
        

    print()

#Main
#====
while True:
    print("Press enter to generate pages")
    input()
    gen_pages()
    
