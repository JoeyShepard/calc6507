from collections import namedtuple
from PIL import Image, ImageFont, ImageDraw 

DEBUG=False

BUTTON_COUNT_X=5
BUTTON_COUNT_Y=8

BUTTON_WIDTH=100
BUTTON_HEIGHT=70
BUTTON_GAP_HORZ=20
BUTTON_GAP_VERT=50
BUTTON_BORDER_HORZ=12
BUTTON_BORDER_VERT=15
FONT_SIZE=50

##BUTTON_WIDTH=50
##BUTTON_HEIGHT=35
##BUTTON_GAP_HORZ=10
##BUTTON_GAP_VERT=25
##BUTTON_BORDER_HORZ=12
##BUTTON_BORDER_VERT=15
##FONT_SIZE=25

IMG_WIDTH=BUTTON_COUNT_X*(BUTTON_WIDTH+BUTTON_GAP_HORZ)+BUTTON_GAP_HORZ
IMG_HEIGHT=BUTTON_COUNT_Y*(BUTTON_HEIGHT+BUTTON_GAP_VERT)+BUTTON_GAP_VERT


if DEBUG:
    BACK_COLOR=(0,0,0)
    FONT_COLOR=(255,0,0)
    BUTTON_COLOR=(192,192,192)
else:
    BACK_COLOR=(0,0,0)
    #BACK_COLOR=(255,255,255)
    FONT_COLOR=(0,0,0)
    
    BUTTON_COLOR=(255,255,255)
    

#Line thickness varies too much
#FONT_NAME="lucon.ttf"   #Lucida Console

#Hmm, too curvy. top and bottom not symetrical
#FONT_NAME="micross.ttf"     #MS Sans Serif

#Too generic
#FONT_NAME="FRABK.TTF"      #Frankling Gothic Book

#Too generic
#FONT_NAME="msgothic.ttc"    #MS Gothic

#pretty good, though lines different widths. lower leg of E too long
#FONT_NAME="segoeui.ttf"

#so so
#FONT_NAME="tahoma.ttf"

#Straighter, clean edges. commas and quotes look wrong
FONT_NAME="calibri.ttf"

#decent
#FONT_NAME="YuGothM.ttc"

#Much better than first two though may need to be blockier
#FONT_NAME="arial.ttf"



keys=[["A","B","C","D","E"],
      [":",";","[","]",","],
      ["'","<","=",">","^"],
      ["ENTER","$",'"',"EE","DEL"],
      ["ALPHA","7","8","9","/"],
      ["STO","4","5","6","*"],
      ["@","1","2","3","-"],
      ["ON","0",".","s","+"]]

charinfo=namedtuple("charinfo",["size","font","yoffset","char"])

OP_SIZE=80
SPECIAL_CHARS=  {"+":charinfo(OP_SIZE,"",0,"")}
SPECIAL_CHARS|= {"-":charinfo(OP_SIZE,"",0,"")}
SPECIAL_CHARS|= {"*":charinfo(OP_SIZE,"",0,"")}
SPECIAL_CHARS|= {"/":charinfo(OP_SIZE,"",0,"")}

img = Image.new('RGB', (IMG_WIDTH, IMG_HEIGHT),BACK_COLOR)
draw_img=ImageDraw.Draw(img)
#https://www.reddit.com/r/learnpython/comments/3fq31t/pil_or_other_means_of_drawing_text_that_is/
draw_img.fontmode="1"

temp_img=Image.new('RGB', (BUTTON_WIDTH, BUTTON_HEIGHT),(0,0,255))
draw_temp=ImageDraw.Draw(temp_img)
draw_temp.fontmode="1"

for row in range(BUTTON_COUNT_Y):
    for column in range(BUTTON_COUNT_X):
        rect_x=BUTTON_GAP_HORZ+column*(BUTTON_WIDTH+BUTTON_GAP_HORZ)
        rect_y=BUTTON_GAP_VERT+row*(BUTTON_HEIGHT+BUTTON_GAP_VERT)
##        draw_img.rectangle([rect_x,
##                            rect_y,
##                            rect_x+BUTTON_WIDTH-1,
##                            rect_y+BUTTON_HEIGHT-1],
##                           fill=BUTTON_COLOR,
##                           outline=BUTTON_COLOR)
        if keys[row][column] in SPECIAL_CHARS.keys():
            font_size=SPECIAL_CHARS[keys[row][column]].size
        else:
            font_size=FONT_SIZE

        
        font_img=ImageFont.truetype(FONT_NAME,size=font_size)
        
        draw_temp.rectangle([0,0,BUTTON_WIDTH-1,BUTTON_HEIGHT-1],
                            fill=BUTTON_COLOR,
                            outline=BUTTON_COLOR)
        if DEBUG:
            draw_temp.line([BUTTON_BORDER_HORZ,0,BUTTON_BORDER_HORZ,BUTTON_HEIGHT],
                           fill=(0,255,0))
            draw_temp.line([BUTTON_WIDTH-BUTTON_BORDER_HORZ,0,
                            BUTTON_WIDTH-BUTTON_BORDER_HORZ,BUTTON_HEIGHT],
                           fill=(0,255,0))
            draw_temp.line([0,BUTTON_BORDER_VERT,BUTTON_WIDTH,BUTTON_BORDER_VERT],
                           fill=(0,255,0))
            draw_temp.line([0,BUTTON_HEIGHT-BUTTON_BORDER_VERT,
                            BUTTON_WIDTH,BUTTON_HEIGHT-BUTTON_BORDER_VERT],
                           fill=(0,255,0))
            
        draw_temp.text((BUTTON_WIDTH/2,
                        BUTTON_HEIGHT/2),
                        keys[row][column],
                        FONT_COLOR,
                        font=font_img,anchor="mm")

        img.paste(temp_img,(rect_x,rect_y))

img.save("keypad.png")
print(IMG_WIDTH,IMG_HEIGHT)
