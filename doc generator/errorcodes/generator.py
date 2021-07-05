from string import Template

#Variables
gen_body=""
gen_rows=""
read_state=0
pic_name=""
pic_info=""
list_mode=False
replace_mode=0
word_name=""

#Constants
WORD_LINK=' <a href="/calc6507/docs/wordlist.html#{}">{}</a>{}'

#Body template
f=open("./templates/body_template.txt")
body_template=f.read()
f.close()

#Row template
row_template=""
f=open("./templates/row_template.txt")
for line in f:
    if line.strip()[0]!="#":
        row_template+=line
f.close()

#Debug template
f=open("./templates/debug_template.txt")
debug_template=f.read()
f.close()

#Read in information
f=open("errors.txt")
for line in f:
    stripped=line.strip()
    if stripped!="":
        if read_state==0:
            pic_name=stripped
            read_state=1
        else:
            if stripped=="%done":
                if list_mode==True:
                    pic_info+="\n\t\t\t\t\t</ul>"
                gen_rows+=Template(row_template).substitute(pic_name=pic_name,pic_info=pic_info)
                pic_info=""
                read_state=0
            else:
                replaced=""
                for word in stripped.split():
                    if replace_mode==0:
                        if word=="%l1":
                            replace_mode=1
                        elif word=="%l2":
                            replace_mode=2
                        else:
                            replaced+=" "+word
                    elif replace_mode==1:
                        if word[-1]==",":
                            comma=","
                            word=word[:-1]
                        else:
                            comma=""
                        replaced+=WORD_LINK.format(word,word,comma)
                        replace_mode=0
                    elif replace_mode==2:
                        word_name=word
                        replace_mode=3
                    elif replace_mode==3:
                        if word[-1]==",":
                            comma=","
                            word=word[:-1]
                        else:
                            comma=""
                        replaced+=WORD_LINK.format(word_name,word,comma)
                        replace_mode=0
                replaced=replaced[1:]
                        
                if pic_info!="":
                    pic_info+="\n"
                if list_mode:
                    if replaced[0]=="-":
                        pic_info+="\t\t\t\t\t\t<li>"+replaced[1:]+"</li>"
                    else:
                        pic_info+="\t\t\t\t\t</ul>\n"
                        pic_info+="\t\t\t\t\t"+replaced
                        list_mode=False
                else:
                    if replaced[0]=="-":
                        pic_info+='\t\t\t\t\t<ul class="error_list">\n'
                        pic_info+="\t\t\t\t\t\t<li>"+replaced[1:]+"</li>"
                        list_mode=True
                    else:
                        pic_info+="\t\t\t\t\t"+replaced
f.close()
            
#Generate table
body=Template(body_template).substitute(body=gen_rows)

f=open("./generated/error_table.txt","wt")
f.write(body)
f.close()

f=open("./generated/errorcodes.html","wt")
f.write(Template(debug_template).substitute(body=body))
f.close()
