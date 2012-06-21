import shapes3d.utils.Rot;

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
  
  void drawBetween(PVector p, PVector q)
  {
    PVector pq = PVector.sub(q,p);
    PVector base = new PVector(0, 0, pq.mag());
    Rot rotation = new Rot(base, pq);
    float x, y;
    PVector r = new PVector(0,0,0), cur;

    pushMatrix();
    translate(p.x, p.y, p.z);
    
    beginShape(QUAD_STRIP);
    for (float a = 0; a <= 2*PI; a += (2*PI / this.faces)) {
      r.x = sin(a) * this.radius;
      r.y = cos(a) * this.radius;
      
      cur = rotation.applyToNew(r);
      vertex(cur.x, cur.y, cur.z);

      cur = rotation.applyTo(PVector.add(base, r));
      vertex(cur.x, cur.y, cur.z);
    }
    endShape();
    
    popMatrix();
  }
}
