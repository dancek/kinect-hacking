class Bone
{
  int jointAType, jointBType;
  PVector jointAPos, jointBPos;
  float radius;
  int user;
  
  ArrayList points;
  ArrayList pointColors;
  
  Cylinder cyl;
  
  PVector ab;    // vector between endpoints
  float length2; // length of ab, squared
  
  Bone(int user, int a, int b)
  {
    this.user = user;
    this.jointAType = a;
    this.jointBType = b;
    this.jointAPos = new PVector();
    this.jointBPos = new PVector();
    this.cyl = new Cylinder();
    this.points = new ArrayList();
    this.pointColors = new ArrayList();
    this.radius = 10;
  }
  
  void draw() {
    // calculate average radius
    float r = 0;
    for (int i=0; i<this.points.size(); ++i) {
      r += (Float) this.points.get(i);
    }
    this.radius = r / this.points.size();
    
    // calculate average color
    if (this.pointColors.size() > 0) {
      colorMode(HSB, 1.0);
      int sz = this.pointColors.size();
      float h=0, s=0, b=0;
      color c;
      for (int i=0; i<sz; ++i) {
        c = (Integer) this.pointColors.get(i);
        h += hue(c);
        s += saturation(c);
        b += brightness(c);
      }
      fill(color(h/sz, s/sz, b/sz));
    }
    
    this.cyl.setRadius(this.radius);
    this.cyl.drawBetween(this.jointAPos, this.jointBPos);

    colorMode(RGB, 255);
  }
  
  void updatePosition(SimpleOpenNI context)
  {
    float confidenceA = context.getJointPositionSkeleton(this.user, this.jointAType, this.jointAPos);
    float confidenceB = context.getJointPositionSkeleton(this.user, this.jointBType, this.jointBPos);
    this.ab = PVector.sub(this.jointBPos, this.jointAPos);
    this.length2 = PVector.dot(ab, ab);
    this.points.clear();
    this.pointColors.clear();
  }
  
  float distanceToPoint(PVector p)
  {
    PVector v = this.jointAPos;
    PVector w = this.jointBPos;
    if (this.length2 == 0.0) {
      return PVector.dist(p,v);
    }
    
    float t = PVector.dot(PVector.sub(p, v), this.ab) / this.length2;
    
    if (t < 0.0) {
      return PVector.dist(p,v);
    }
    if (t > 1.0) {
      return PVector.dist(p,w);
    }
    
    PVector projection = PVector.add(v, PVector.mult(ab, t));
    return PVector.dist(p, projection);
  }
  
  void addPoint(PVector p, float distance)
  {
    this.points.add(distance);
  }

  void addPoint(PVector p, float distance, color c)
  {
    this.points.add(distance);
    this.pointColors.add(c);
  }
}

class Torso extends Bone
{
  Torso(int user, int a, int b)
  {
    super(user, a, b);
  }
}

