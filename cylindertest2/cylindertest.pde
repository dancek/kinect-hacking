import processing.opengl.*;

Cylinder c;
float xrot, yrot;

void setup() {
  size(640, 360, OPENGL);
  c = new Cylinder(0.2, 15);
  xrot=0; yrot=0;
}

void draw() {
  background(#000000);
  noStroke();
  fill(#cccccc);
  
  pushMatrix();
  translate(width/2,height/2,0);
  scale(100);
  rotateX(xrot);
  rotateY(yrot);

  noLights();
  lightSpecular(1.0,1.0,1.0);
  pointLight(255,255,255,10,-5,-5);
  pointLight(192,192,192,-5,10,10);
  pointLight(192,192,192,-5,-10,-5);

  float s = mouseX / float(width);
  specular(s);
  ambient(0);
  shininess(0);
  emissive(0.5);
  
  c.draw();
  
  translate(1,0,0);
  box(1);

  translate(-2,0,0);
  sphere(0.5);
  
  popMatrix();
}

void mouseDragged() {
  float c = 0.01;
  yrot += c * (mouseX - pmouseX);
  xrot -= c * (mouseY - pmouseY);
}
