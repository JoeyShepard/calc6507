//scales 10 SVG units to 1mm
//7mm tall buttons with 1.5mm room is 4mm font!
//slicer garbles ENT (smaller than 4mm), @, and space
//SCALE_VALUE=[0.1,0.1,1]

//version k1
//8mm tall font
SCALE_VALUE=[0.2,0.2,1];

difference()
{
    translate([0,-70,0])
    scale(SCALE_VALUE)
    linear_extrude(height=1)
    import("keypad_path.svg");
    
    //cut off all but top 5 letters for testing
    translate([0,-230,-1])
    cube([150,200,3],center=false);
}
