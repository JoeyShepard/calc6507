from collections import namedtuple

DEBUG=True

BUTTON_COUNT_X=5
BUTTON_COUNT_Y=8

BUTTON_WIDTH=120
BUTTON_HEIGHT=80
BUTTON_GAP_HORZ=32.4
BUTTON_GAP_VERT=72.4
BUTTON_BORDER_HORZ=15
BUTTON_BORDER_VERT=15
FONT_SIZE=72
FONT_OFFSET_Y=5

IMG_WIDTH=BUTTON_COUNT_X*(BUTTON_WIDTH+BUTTON_GAP_HORZ)+BUTTON_GAP_HORZ
IMG_HEIGHT=BUTTON_COUNT_Y*(BUTTON_HEIGHT+BUTTON_GAP_VERT)+BUTTON_GAP_VERT

if DEBUG:
    BACK_COLOR="black"
    FONT_COLOR="red"
    BUTTON_COLOR="#C0C0C0"
    LINE_COLOR="#00FF00"
else:
    #BACK_COLOR="black"
    BACK_COLOR="white"
    FONT_COLOR="black"
    BUTTON_COLOR="white"
    LINE_COLOR="00FF00"  #not used


#NOTE: font names tested with raster versions. WON'T WORK WITH SVG!    

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
#FONT_NAME="calibri.ttf"

#decent
#FONT_NAME="YuGothM.ttc"

#Much better than first two though may need to be blockier
#Best looking in raster version
#FONT_NAME="arial.ttf"

#Favorite in SVG version, though inkscape renders as a different font
#FONT_NAME="monospace"

#What Chrome is actually rendering for "monospace"
FONT_NAME="Consolas"


keys=[["A","B","C","D","E"],
      [":",";","[","]",","],
      ["'","<","=",">","^"],
      ["ENTER","$",'"',"EE","DEL"],
      ["ALPHA","7","8","9","/"],
      ["STO","4","5","6","*"],
      ["@","1","2","3","-"],
      ["ON","0","."," ","+"]]

charinfo=namedtuple("charinfo",["size","font","weight","offset_y","char"])

SPECIAL_CHARS=  {}
SPECIAL_CHARS|= {":":charinfo(0,"","",1,"")}
SPECIAL_CHARS|= {";":charinfo(0,"","",1,"")}
SPECIAL_CHARS|= {",":charinfo(0,"","",1,"")}

SPECIAL_CHARS|= {"[":charinfo(54,"","bold",1,"")}
SPECIAL_CHARS|= {"]":charinfo(54,"","bold",1,"")}

SPECIAL_CHARS|= {"'":charinfo(90,"","",15,"")}
SPECIAL_CHARS|= {"<":charinfo(90,"","",2,"")}
SPECIAL_CHARS|= {"=":charinfo(90,"","",2,"")}
SPECIAL_CHARS|= {">":charinfo(90,"","",2,"")}
SPECIAL_CHARS|= {"^":charinfo(120,"","",28,"")}

SPECIAL_CHARS|= {"ENTER":charinfo(60,"","",0,"ENT")}
SPECIAL_CHARS|= {"$":charinfo(66,"calibri","",0,"")} #no cross bar
SPECIAL_CHARS|= {'"':charinfo(90,"","",15,"")}
SPECIAL_CHARS|= {"DEL":charinfo(66,"","",8,"&#x1F868;")}

SPECIAL_CHARS|= {"ALPHA":charinfo(84,"","",0.5,"a")}

OP_SIZE=100
SPECIAL_CHARS|= {"+":charinfo(OP_SIZE,"","",2,"")}
SPECIAL_CHARS|= {"-":charinfo(OP_SIZE,"","",2,"")}
SPECIAL_CHARS|= {"*":charinfo(OP_SIZE,"","",2,"&#xD7;")}
SPECIAL_CHARS|= {"/":charinfo(OP_SIZE,"","",2,"&#xF7;")}

SPECIAL_CHARS|= {"STO":charinfo(66,"","",8,"&#x1F86A;")}
SPECIAL_CHARS|= {"@":charinfo(66,"calibri","bold",-0,"")} #rounder, easier to print
SPECIAL_CHARS|= {".":charinfo(0,"","",1,"")}
#Looks correct in Chrome but way too big and wrong shape in inkscape :( :( :(
#SPECIAL_CHARS|= {" ":charinfo(120,"","",-28,"&#x2423;")}
#Doesn't render at all in inkscape :( :( :(
#SPECIAL_CHARS|= {" ":charinfo(0,"","",0,"&#x2334;")}

#Technically not the space character, but looks right in Chrome and inkscape
#SPECIAL_CHARS|= {" ":charinfo(0,"","",0,"&#x2334;")}

#Trying this for now
SPECIAL_CHARS|= {" ":charinfo(0,"","",0,"SP")}

f=open("keypad.svg","w")

f.write('<svg xmlns="http://www.w3.org/2000/svg" ')
f.write(f'width="{IMG_WIDTH}" height="{IMG_HEIGHT}">\n')
if DEBUG:
    f.write(f'<rect width="100%" height="100%" fill="{BACK_COLOR}" />\n\n')

for row in range(BUTTON_COUNT_Y):
    for column in range(BUTTON_COUNT_X):
        rect_x=BUTTON_GAP_HORZ+column*(BUTTON_WIDTH+BUTTON_GAP_HORZ)
        rect_y=BUTTON_GAP_VERT+row*(BUTTON_HEIGHT+BUTTON_GAP_VERT)

        #default values
        font_size=FONT_SIZE
        font_name=FONT_NAME
        font_weight=""
        font_offset_y=FONT_OFFSET_Y
        font_char=keys[row][column]

        #character adjustments
        if keys[row][column] in SPECIAL_CHARS.keys():

            #font size
            if SPECIAL_CHARS[keys[row][column]].size!=0:
                font_size=SPECIAL_CHARS[keys[row][column]].size

            #font name
            if SPECIAL_CHARS[keys[row][column]].font!="":
                font_name=SPECIAL_CHARS[keys[row][column]].font

            #font weight
            font_weight=SPECIAL_CHARS[keys[row][column]].weight
                
            #font y offset
            if SPECIAL_CHARS[keys[row][column]].offset_y!=0:
                font_offset_y=SPECIAL_CHARS[keys[row][column]].offset_y
                
            #font character replacement
            if SPECIAL_CHARS[keys[row][column]].char!="":
                font_char=SPECIAL_CHARS[keys[row][column]].char
        
        #button
        if DEBUG:
            f.write(f'<rect width="{BUTTON_WIDTH}" height="{BUTTON_HEIGHT}" ')
            f.write(f'x="{rect_x}" y="{rect_y}" fill="{BUTTON_COLOR}" />\n')

        #debug lines
        if DEBUG:
            f.write(f'<line x1="{rect_x+BUTTON_BORDER_HORZ}" y1="{rect_y}" ')
            f.write(f'x2="{rect_x+BUTTON_BORDER_HORZ}" y2="{rect_y+BUTTON_HEIGHT}" ')
            f.write(f'style="stroke:{LINE_COLOR};stroke-width:1" />\n')

            f.write(f'<line x1="{rect_x+BUTTON_WIDTH-BUTTON_BORDER_HORZ}" y1="{rect_y}" ')
            f.write(f'x2="{rect_x+BUTTON_WIDTH-BUTTON_BORDER_HORZ}" y2="{rect_y+BUTTON_HEIGHT}" ')
            f.write(f'style="stroke:{LINE_COLOR};stroke-width:1" />\n')

            f.write(f'<line x1="{rect_x}" y1="{rect_y+BUTTON_BORDER_VERT}" ')
            f.write(f'x2="{rect_x+BUTTON_WIDTH}" y2="{rect_y+BUTTON_BORDER_VERT}" ')
            f.write(f'style="stroke:{LINE_COLOR};stroke-width:1" />\n')

            f.write(f'<line x1="{rect_x}" y1="{rect_y+BUTTON_HEIGHT-BUTTON_BORDER_VERT}" ')
            f.write(f'x2="{rect_x+BUTTON_WIDTH}" y2="{rect_y+BUTTON_HEIGHT-BUTTON_BORDER_VERT}" ')
            f.write(f'style="stroke:{LINE_COLOR};stroke-width:1" />\n')
            
        #draw text
        f.write(f'<text x="{rect_x+BUTTON_WIDTH/2}" y="{rect_y+BUTTON_HEIGHT/2+font_offset_y}" ')
        f.write(f'fill="{FONT_COLOR}" dominant-baseline="middle" text-anchor="middle" ')
        if font_weight!="": f.write(f'font-weight="{font_weight}" ')
        f.write(f'font-family="{font_name}" font-size="{font_size}">')
        f.write(f'{"&lt;" if font_char=="<" else font_char}</text>\n\n')
  
f.write("</svg>")
f.close()

print(IMG_WIDTH,IMG_HEIGHT)
