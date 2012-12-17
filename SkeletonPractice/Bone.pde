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
  
  String name;   // name of bone
  
  Bone(int user, int a, int b)
  {
    this(user, "", a, b);
  }
  
  Bone(int user, String name, int a, int b)
  {
    this.name = name;
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
    float radius_ = 0;
    for (int i=0; i<this.points.size(); ++i) {
      radius_ += (Float) this.points.get(i);
    }
    this.radius = radius_ / this.points.size();
    
    // calculate average color
    if (this.pointColors.size() > 0) {
      colorMode(RGB, 255);
      int sz = this.pointColors.size();
      float r=0, g=0, b=0;
      color c;
      for (int i=0; i<sz; ++i) {
        c = (Integer) this.pointColors.get(i);
        r += red(c);
        g += green(c);
        b += blue(c);
      }
      fill(color(r/sz, g/sz, b/sz));
    }
    
    noStroke();
    this.cyl.setRadius(this.radius);
    this.cyl.drawBetween(this.jointAPos, this.jointBPos);
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

