class Bone
{
  int jointAType, jointBType;
  PVector jointAPos, jointBPos;
  float radius;
  int user;
  
  ArrayList points;
  
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
    this.radius = 10;
  }
  
  void draw() {
    float r = 0;
    for (int i=0; i<this.points.size(); ++i) {
      r += (Float) this.points.get(i) / this.points.size();
    }
    this.radius = r;
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
}

class Torso extends Bone
{
  Torso(int user, int a, int b)
  {
    super(user, a, b);
  }
}

