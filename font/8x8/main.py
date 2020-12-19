#https://int10h.org/oldschool-pc-fonts/fontlist/

from graphics import *

f=open("font_8x8.asm","w")
fp=open("font_8x8.py","w")

fp.write("chars={}\n")

font_img=Image(Point(274,29),"8x8.png")

for i in range(2):
    for j in range(32):
        out_str=";"+chr(32+i*32+j)+"\n  FCB "
        py_str="chars["+str(32+i*32+j)+"]=["
        for cy in range(8):
            byte_data=0
            for cx in range(8):
                byte_data<<=1
                px=13+j*16+cx*2
                py=9+i*16+cy*2
                read_pixel=font_img.getPixel(px,py)
                if read_pixel==[255,255,255]:
                    font_img.setPixel(px,py,"blue")
                else:
                    font_img.setPixel(px, py, "red")
                    byte_data+=1
            out_str+="$"+str(hex(byte_data))[2:]
            py_str+=hex(byte_data)
            if cy!=7:
                out_str+=", "
                py_str+=", "
        f.write(out_str+"\n\n")
        fp.write(py_str+"]\n")

font_img.save("output.png")

f.close()
fp.close()

#win=GraphWin("Font",547,58)
#font_img.draw(win)
#win.getMouse()
#win.close()
