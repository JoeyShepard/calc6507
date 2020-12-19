
from graphics import *

f=open("font_5x8.asm","w")

font_img=Image(Point(20,48),"5x8.png")

for i in range(12):
    for j in range(8):
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
            f.write(out_str+"\n\n")

font_img.save("output.png")

f.close()

#win=GraphWin("Font",547,58)
#font_img.draw(win)
#win.getMouse()
#win.close()
