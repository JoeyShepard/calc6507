#!/usr/bin/env python3

from graphics import *
import os

f=open("font_5x8_flipped.asm","w")

selected_font="5x8 square.png"

font_img=Image(Point(20,48),selected_font)

done=False
for i in range(12):
    for j in range(8):
        #don't need lowercase font
        if chr(32+i*8+j)=="a":
            done=True
            break
        if chr(32+i*8+j)=="\\":
            out_str=";back slash\n  FCB "
        else:
            out_str=";"+chr(32+i*8+j)+"\n  FCB "
        #for cx in range(5):
        #for cx in range(4,-1,-1):
        for cx in range(5):
            byte_data=0
            for cy in range(8):    
                byte_data<<=1
                px=1+j*6+cx
                py=i*8+cy
                read_pixel=font_img.getPixel(px,py)
                if read_pixel==[0,0,0]:
                    font_img.setPixel(px,py,"blue")
                    byte_data+=1
                else:
                    font_img.setPixel(px, py, "red")
                    
            #Added here to flip byte
            new_val=0
            for _ in range(8):
                new_val<<=1
                if byte_data&1:
                    new_val|=1
                byte_data>>=1
            byte_data=new_val
            
            out_str+="$"+str(hex(byte_data))[2:]
            
            #if cx!=4:
            #if cx!=0:
            if cx!=4:
                out_str+=", "
        if i*8+j!=95:
            f.write(out_str+"\n\n")
    if done:
        break
   
    # font_img.save("output\\"+font)

f.close()

#OLD - switched to Linux since then
#Update font file in source
#os.system("copy font_5x8.asm ..\\..\\src\\font_5x8.asm")
#os.system("copy font_debug.asm ..\\..\\src\\font_debug.asm")

#DOESN'T WORK - will not run "from graphics import *" since no
#display connected on headless though no display needed

#WORKED - ran through PuTTY with X server
#Update font file in source
#os.system("cp font_5x8.asm ../../src/font_5x8.asm")
#os.system("cp font_debug.asm ../../src/font_debug.asm")

#win=GraphWin("Font",547,58)
#font_img.draw(win)
#win.getMouse()
#win.close()
