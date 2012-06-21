class Cylinder {
  
  int faces;
  float radius;
  
  Cylinder() {
    this(1.0, 30);
  }
  
  Cylinder(float radius, int faces) {
    this.radius = radius;
    this.faces = faces;
  }
  
  void draw() {
    float x, y;
    beginShape(QUAD_STRIP); 
    for (float a = 0; a <= 2*PI; a += (2*PI / this.faces)) {
      x = sin(a) * this.radius;
      y = cos(a) * this.radius;
      vertex(x,y,-1); 
      vertex(x,y,1); 
    }
    endShape();
  }
}
