//Taken from Python key label script...
BUTTON_COUNT_X=5;
BUTTON_COUNT_Y=8;

BUTTON_WIDTH=120;
BUTTON_HEIGHT=80;
BUTTON_GAP_HORZ=32.4;
BUTTON_GAP_VERT=72.4;
//BUTTON_BORDER_HORZ=20;
//BUTTON_BORDER_VERT=20;

//Added here
BUTTON_THICKNESS=40;

BUTTON_LIP_WIDTH=0; //harder to mold
BUTTON_LIP_HEIGHT=10;
BUTTON_LIP_THICKNESS=12;

SPINE_WIDTH=5*BUTTON_WIDTH+4*BUTTON_GAP_HORZ+BUTTON_LIP_WIDTH*2;
SPINE_HEIGHT=40;
SPINE_THICKNESS=BUTTON_LIP_THICKNESS;

SPRUE_WIDTH=12;
SPRUE_LENGTH=100;
SPRUE_THICKNESS=12;
SPRUE_X_OFFSET=15;
SPRUE_Y_OFFSET=0;

MOLD_BOTTOM_THICKNESS=20;
MOLD_WALL_THICKNESS=30;
MOLD_INNER_WIDTH=900;
MOLD_INNER_HEIGHT=300;
MOLD_INNER_THICKNESS=150;

scale([0.1,0.1,0.1])
{
  union()
  {
    translate([100,120,0])
      key_row();
    mold_box();
  }
}


module mold_box()
{
  difference()
  {
    translate([0,0,-MOLD_BOTTOM_THICKNESS])
    cube([MOLD_INNER_WIDTH+
      MOLD_WALL_THICKNESS*2,
      MOLD_INNER_HEIGHT+MOLD_WALL_THICKNESS*2,
      MOLD_BOTTOM_THICKNESS+MOLD_INNER_THICKNESS]);
    translate([MOLD_WALL_THICKNESS,
      MOLD_WALL_THICKNESS,0])
    cube([MOLD_INNER_WIDTH,MOLD_INNER_HEIGHT,
      MOLD_INNER_THICKNESS+
      MOLD_BOTTOM_THICKNESS]);
  }
}


module key_row()
{

union()
{

for (i=[0:BUTTON_COUNT_X-1])
{
  translate([(BUTTON_WIDTH+BUTTON_GAP_HORZ)*i,
  0,0])
  {
    union()
    {

      //Bottom lip
      //(note lip on bottom AND top!!!)
      cube([BUTTON_LIP_WIDTH*2+BUTTON_WIDTH,
        BUTTON_LIP_HEIGHT*2+BUTTON_HEIGHT,
        BUTTON_LIP_THICKNESS]);

      //Button
      translate([BUTTON_LIP_WIDTH,
        BUTTON_LIP_HEIGHT,0])
      cube([BUTTON_WIDTH,
        BUTTON_HEIGHT,
        BUTTON_THICKNESS]);

      //Try with one sided dump mold first
      /*
      //Sprue
      translate([SPRUE_X_OFFSET,
        SPRUE_Y_OFFSET,0])
      rotate([0,0,150])
      cube([SPRUE_WIDTH,SPRUE_LENGTH,
        SPRUE_THICKNESS]);
      */
    }
  }
}

//Spine
translate([0,BUTTON_LIP_HEIGHT*2+BUTTON_HEIGHT,
  0])
cube([SPINE_WIDTH, SPINE_HEIGHT,
  SPINE_THICKNESS]);

}

}