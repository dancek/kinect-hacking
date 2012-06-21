import processing.opengl.*;

import shapes3d.utils.Rot;

import peasy.*;

PeasyCam cam;
Tube tube;

void setup()
{
  size(640,360, OPENGL);
  cam = new PeasyCam(this, 1000);
  tube = new Tube(this, 1, 30);
  tube.setSize(10,10,10,10);
  tube.fill(#ffcc66);
  tube.fill(#ffcc66, 1);
}

void draw()
{
  background(#000000);
  stroke(#cccccc);
  fill(#ff0000);
  
  float ax=100, ay=100, az=0, bx=250, by=290, bz=50;
  
  line(ax, ay, az, bx, by, bz);
  translate(100,0,0);
  //drawCylinder(ax, ay, az, bx, by, bz, 20);
  translate(100,0,0);
  tube.setWorldPos(ax,ay,az, bx,by,bz);
  tube.draw();
}

/**
 * Draw a cylinder from point a to point b with radius r.
 */
void drawCylinder(float ax, float ay, float az, float bx, float by, float bz, float r)
{
  PVector target = new PVector(bx-ax, by-ay, bz-az);
  Rot rotation = new Rot(new PVector(1,0,0), target);

  pushMatrix();
  translate(ax, ay, az);
  rotateX(-atan(bx/ax));
  rotateY(-atan(by/ay));
  rotateZ(-atan(bz/az));
  scale(p.mag());
  line(0, 0, 0, -1, 0, 0); //bx-ax, by-ay, bz-az);
  popMatrix();
}

