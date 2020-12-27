from graphics import *
import sys

font_src=Image(Point(520,264),"calculator fonts.png")
#examples are broken!!!
#font_dest=Image(520,264)
font_dest=Image(Point(260,134),"output.png")

for cy in range(264):
    for cx in range(520):
        color=font_src.getPixel(cx*2,cy*2)
        font_dest.setPixel(cx,cy,color_rgb(color[0],color[0],color[0]))
        
font_dest.save("output.png")
