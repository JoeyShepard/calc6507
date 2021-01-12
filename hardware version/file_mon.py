#File monitor for ROM images
#Notifies when timestamp on file changes indicating sync with Google Drive

import sys, os, time, ctypes

def time_str():
    new_time=time.localtime()
    return f"{new_time.tm_hour:02}:{new_time.tm_min:02}.{new_time.tm_sec:02}"

print("File monitor for ROM images")
print("===========================")
if len(sys.argv)==1:
    print("No argument given. Defaulting to processed.hex\n")
    mon_file="processed.hex"
else:
    mon_file=sys.argv[1]

print("["+time_str()+"] Started monitoring "+mon_file)

last_update=os.path.getmtime(mon_file)
while(1):
    time.sleep(1)
    new_update=os.path.getmtime(mon_file)
    if new_update!=last_update:
        last_update=new_update
        print(chr(13)+"["+time_str()+"] UPDATE to "+mon_file+"\a")
        ctypes.windll.user32.FlashWindow(ctypes.windll.kernel32.GetConsoleWindow(),True)
    print(chr(13)+time_str(),end="")
        
