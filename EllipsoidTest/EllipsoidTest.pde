import processing.opengl.*;
import controlP5.*;
import peasy.*;
import shapes3d.*;

ControlP5 controlP5;
PeasyCam cam;
Ellipsoid e;

float x=30.0, y=30.0, z=30.0;
boolean wireframe = true;

void setup()
{
  size(640,640,OPENGL);
  cam = new PeasyCam(this, 100);

  perspective(PI/3.0, width/height, 10.0, 1000.0);
  
  controlP5 = new ControlP5(this);
  controlP5.addSlider("x");
  controlP5.addSlider("y");
  controlP5.addSlider("z");
  controlP5.setAutoDraw(false);
  
  e = new Ellipsoid(this, 50, 50);
  e.strokeWeight(1.0);
  e.stroke(#ffffff);
}

void draw()
{
  background(0);
  lights();
  
  e.setRadius(x,y,z);
  
  if (wireframe) {
    e.drawMode(e.WIRE);
  } else {
    e.drawMode(e.SOLID);
  }
  e.draw();
  
  cam.beginHUD();
  controlP5.draw();
  cam.endHUD();
}

void keyPressed()
{
  if (key == ' ') {
    wireframe = !wireframe;
  }
}
