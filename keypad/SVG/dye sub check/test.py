
DEBUG=False

#Test print is 4x4 inches
IMG_WIDTH=400
IMG_HEIGHT=400

MM_TO_INCH100=100/254

BUTTON_WIDTH=120*MM_TO_INCH100
BUTTON_HEIGHT=80*MM_TO_INCH100
BUTTON_GAP_HORZ=32.4*MM_TO_INCH100
BUTTON_GAP_VERT=72.4*MM_TO_INCH100
BUTTON_BORDER_HORZ=20
BUTTON_BORDER_VERT=20


FONT_NAME="Consolas"
FONT_SIZE=12

#For debugging
BACK_COLOR="#C0C0FF"

def draw_line(x1,y1,x2,y2,color="black"):
    f.write(f'<line x1="{x1}" y1="{y1}" ')
    f.write(f'x2="{x2}" y2="{y2}" ')
    f.write(f'style="stroke:{color};stroke-width:1" />\n')

def draw_box(x1,y1,x2,y2,color="black"):
    f.write(f'<line x1="{x1}" y1="{y1}" ')
    f.write(f'x2="{x2}" y2="{y1}" ')
    f.write(f'style="stroke:{color};stroke-width:1" />\n')

    f.write(f'<line x1="{x2}" y1="{y1}" ')
    f.write(f'x2="{x2}" y2="{y2}" ')
    f.write(f'style="stroke:{color};stroke-width:1" />\n')

    f.write(f'<line x1="{x2}" y1="{y2}" ')
    f.write(f'x2="{x1}" y2="{y2}" ')
    f.write(f'style="stroke:{color};stroke-width:1" />\n')

    f.write(f'<line x1="{x1}" y1="{y2}" ')
    f.write(f'x2="{x1}" y2="{y1}" ')
    f.write(f'style="stroke:{color};stroke-width:1" />\n')

def draw_rect(x1,y1,x2,y2,color="black"):
    f.write(f'<rect x="{x1}" y="{y1}" ')
    f.write(f'width="{x2-x1}" height="{y2-y1}" ')
    f.write(f'style="fill:{color};stroke-width:0" />')

def draw_text(text,x,y,color="black",size=FONT_SIZE, center=False, bold=False):
    f.write(f'<text x="{x}" y="{y}" fill="{color}" ')
    if center:
        f.write(f'dominant-baseline="middle" text-anchor="middle" ')
    else:
        f.write(f'dominant-baseline="bottom" text-anchor="left" ')
    if bold:
        f.write('font-weight="bold" ')
    f.write(f'font-family="{FONT_NAME}" font-size="{size}">')
    f.write(f'{text.replace("<","&lt;")}</text>\n\n')

f=open("test print.svg","w")

f.write('<svg xmlns="http://www.w3.org/2000/svg" ')
f.write(f'width="{IMG_WIDTH}" height="{IMG_HEIGHT}">\n')

if DEBUG:
    f.write(f'<rect width="100%" height="100%" fill="{BACK_COLOR}" />\n\n')

#Small box in each corner
BOX_SIZE=12
draw_box(0,0,BOX_SIZE,BOX_SIZE)
draw_box(0,IMG_WIDTH-BOX_SIZE,BOX_SIZE,IMG_WIDTH)
draw_box(IMG_WIDTH-BOX_SIZE,0,IMG_WIDTH,BOX_SIZE)
draw_box(IMG_WIDTH-BOX_SIZE,IMG_HEIGHT-BOX_SIZE,IMG_WIDTH,IMG_HEIGHT)

#Inch for scale
draw_line(20,20,20,60)
draw_line(120,20,120,60)
draw_line(20,40,120,40,"black")
draw_text("1 inch",25,35,"black",24)

#Button holes for scale
for i in range(4):
    box_x=i*(BUTTON_WIDTH+BUTTON_GAP_HORZ)+150
    draw_box(box_x,20,box_x+BUTTON_WIDTH,20+BUTTON_HEIGHT)

#Row 1
ROW_Y=90
for i in range(6):
    box_x=i*(BUTTON_WIDTH+BUTTON_GAP_HORZ)+20
    if DEBUG:
        draw_box(box_x,ROW_Y,box_x+BUTTON_WIDTH,ROW_Y+BUTTON_HEIGHT)
    draw_text("Test",box_x+BUTTON_WIDTH/2,ROW_Y+BUTTON_HEIGHT/2,"black",18,True,True)

#Row 2
ROW_Y+=BUTTON_HEIGHT+BUTTON_GAP_VERT
for i in range(6):
    box_x=i*(BUTTON_WIDTH+BUTTON_GAP_HORZ)+20
    if DEBUG:
        draw_box(box_x,ROW_Y,box_x+BUTTON_WIDTH,ROW_Y+BUTTON_HEIGHT)
    draw_text("Test",box_x+BUTTON_WIDTH/2,ROW_Y+BUTTON_HEIGHT/2,"black",16,True,False)

#Row 3
ROW_Y+=BUTTON_HEIGHT+BUTTON_GAP_VERT
for i in range(6):
    box_x=i*(BUTTON_WIDTH+BUTTON_GAP_HORZ)+20
    if DEBUG:
        draw_box(box_x,ROW_Y,box_x+BUTTON_WIDTH,ROW_Y+BUTTON_HEIGHT)
    draw_text("Test",box_x+BUTTON_WIDTH/2,ROW_Y+BUTTON_HEIGHT/2,"black",14,True,False)

colors=["red","blue","green","purple","#D0D000","black"]

#Row 4
ROW_Y+=BUTTON_HEIGHT+BUTTON_GAP_VERT
for i in range(6):
    box_x=i*(BUTTON_WIDTH+BUTTON_GAP_HORZ)+20
    if DEBUG:
        draw_box(box_x,ROW_Y,box_x+BUTTON_WIDTH,ROW_Y+BUTTON_HEIGHT)
    draw_text("Test",box_x+BUTTON_WIDTH/2,ROW_Y+BUTTON_HEIGHT/2,colors[i],18,True,False)

#Row 5
ROW_Y+=BUTTON_HEIGHT+BUTTON_GAP_VERT
for i in range(6):
    box_x=i*(BUTTON_WIDTH+BUTTON_GAP_HORZ)+20
    draw_rect(box_x,ROW_Y,box_x+BUTTON_WIDTH,ROW_Y+BUTTON_HEIGHT,colors[i])
    if DEBUG:
        draw_box(box_x,ROW_Y,box_x+BUTTON_WIDTH,ROW_Y+BUTTON_HEIGHT)
    draw_text("Test",box_x+BUTTON_WIDTH/2,ROW_Y+BUTTON_HEIGHT/2,"white",18,True,False)



f.write("</svg>")
f.close()
