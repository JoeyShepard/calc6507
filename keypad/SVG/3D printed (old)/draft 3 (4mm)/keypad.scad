
//version k2
//scales 10 SVG units to 1mm
//4mm tall font
SCALE_VALUE=[0.1,0.1,1];

difference()
{
    //translate([0,-70,0])
    scale(SCALE_VALUE)
    linear_extrude(height=2)
    import("keypad_path.svg",center=true);
    
    cut off all but top 5 letters for testing
    translate([0,-220,-1])
    cube([150,200,3],center=false);
}
