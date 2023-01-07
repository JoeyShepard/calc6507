#Constants below taken from 3D printed mold
BUTTON_COUNT=5

BUTTON_WIDTH=120
BUTTON_HEIGHT=80
BUTTON_GAP_HORZ=32.4
BUTTON_GAP_VERT=72.4

BUTTON_THICKNESS=40

BUTTON_LIP_WIDTH=0
BUTTON_LIP_HEIGHT=10
BUTTON_LIP_THICKNESS=12

SPINE_WIDTH=BUTTON_COUNT*BUTTON_WIDTH+(BUTTON_COUNT-1)*BUTTON_GAP_HORZ+BUTTON_LIP_WIDTH*2
SPINE_HEIGHT=40
SPINE_THICKNESS=BUTTON_LIP_THICKNESS

#Colors
COLOR_BUTTON="red"
COLOR_OTHER="blue"

#Adjusted here to fit
OFFSET_X=40
OFFSET_Y=40

IMG_WIDTH=SPINE_WIDTH+2*OFFSET_X
IMG_HEIGHT=800
BACK_COLOR="gray"

LEGEND=False

#Variables
last_x=OFFSET_X
last_y=OFFSET_Y

#Functions
def rect(f,width,height,color=COLOR_OTHER):
    global last_x, last_y
    f.write(f'<rect width="{width}" ')
    f.write(f'height="{height}" ')
    f.write(f'x="{last_x}" y="{last_y}" fill="{color}" />\n')

def up(amount):
    global last_y
    last_y-=amount
    
def down(amount):
    global last_y
    last_y+=amount
    
def left(amount):
    global last_x
    last_x-=amount
    
def right(amount):
    global last_x
    last_x+=amount
    
#Main code
f=open("keypad.svg","w")

f.write('<svg xmlns="http://www.w3.org/2000/svg" ')
f.write(f'width="{IMG_WIDTH}" height="{IMG_HEIGHT}">\n')

f.write(f'<rect width="100%" height="100%" fill="{BACK_COLOR}" />\n\n')

#Spine
rect(f,SPINE_WIDTH,SPINE_HEIGHT)

#Buttons
down(SPINE_HEIGHT)
for i in range(BUTTON_COUNT):
    #Spine
    rect(f,BUTTON_WIDTH,BUTTON_HEIGHT+BUTTON_LIP_HEIGHT*2)
    down(BUTTON_LIP_HEIGHT)
    #Button
    rect(f,BUTTON_WIDTH,BUTTON_HEIGHT,COLOR_BUTTON)
    up(BUTTON_LIP_HEIGHT)
    right(BUTTON_WIDTH+BUTTON_GAP_HORZ)

f.write('</svg>')
f.close()

#Print sizes for annotating image
def adjust(num):
    return str(num/10)+"mm"

print(f'Overall width: {adjust(SPINE_WIDTH)}')
print(f'Overall height: {adjust(SPINE_HEIGHT+BUTTON_HEIGHT+BUTTON_LIP_HEIGHT*2)}')
print(f'Button width: {adjust(BUTTON_WIDTH)}')
print(f'Button height: {adjust(BUTTON_HEIGHT)}')
print(f'Lip height: {adjust(BUTTON_LIP_HEIGHT)}')
print(f'Button gap: {adjust(BUTTON_GAP_HORZ)}')
