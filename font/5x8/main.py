
from graphics import *
import os

f=open("font_5x8.asm","w")
f_debug=open("font_debug.asm","w")

#font_img=Image(Point(20,48),"5x8.png")
#font_img=Image(Point(20,48),"5x8 square.png")
#font_img=Image(Point(20,48),"5x8 fat.png")
#font_img=Image(Point(20,48),"5x8 fat rounded.png")

selected_font="5x8 square.png"

font_counter=1
for font in ["5x8.png", "5x8 square.png", "5x8 fat.png", "5x8 fat rounded.png"]:
    font_img=Image(Point(20,48),font)

    f_debug.write("font"+str(font_counter)+":\n\n")
    font_counter+=1
    
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
                out_str+="$"+str(hex(byte_data))[2:]
                if cx!=4:
                    out_str+=", "
            if i*8+j!=95:
                f_debug.write(out_str+"\n\n")
                if font==selected_font:
                    f.write(out_str+"\n\n")
        if done:
            break
    
    f_debug.write('  %include "font_custom.asm"\n\n\n')
    font_img.save("output\\"+font)

#table for font debugging
f_debug.write("DEBUG_FONT_COUNT set "+str(font_counter-1)+"\n")
f_debug.write("font_counter:\n  FCB 0\n")
f_debug.write("debug_fonts:\n")

for i in range(font_counter-1):
    #f_debug.write("  FDB font"+str(i+1)+"\n")
    f_debug.write("  FCB font"+str(i+1)+" % 256\n")
    f_debug.write("  FCB font"+str(i+1)+" / 256\n")


f.close()
f_debug.close()

#Update font file in source
os.system("copy font_5x8.asm ..\\..\\src\\font_5x8.asm")
os.system("copy font_debug.asm ..\\..\\src\\font_debug.asm")


#win=GraphWin("Font",547,58)
#font_img.draw(win)
#win.getMouse()
#win.close()
