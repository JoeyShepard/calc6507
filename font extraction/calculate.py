
#calculate bytes in font to see if compression in possible

from font_8x8 import *

uniques=set()
size=0

for i in chars.values():
    for j in i:
        uniques.add(j)
        size+=1

print("unique bytes:",len(uniques))
#41, so 6 bit encoding is possible
#encode something else in left over space?

#store strings as normal but encode font data only

print("total bytes:",size)
#512 bytes
#6 bit encoding would be 384 bytes
#fit decoder in 128 bytes???
    #seems very tiny gain
    # hmm, * 3/4 is easy
    # wait until LCD in place then

#only a handful had zeroes on end
#unlikely that decompresser would fit in that many bytes
