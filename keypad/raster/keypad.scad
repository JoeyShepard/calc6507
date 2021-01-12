/*
scale([0.1,0.1,0.005])    
surface(file="keypad.png", invert=true);

translate([36,30,0])
color([0,0,1])
linear_extrude(height=1)
text("5", font="Arial", size=3.7);
*/

//scale([0.1,0.1,0.005])    
//surface(file="letter_A.png", invert=true);

translate([10,1.5,0])
color([0,0,1])
linear_extrude(height=1)
text("A", font="Arial", size=4);