class Bone
{
  int jointAType, jointBType;
  PVector jointAPos, jointBPos;
  int user;
  
  Bone(int user, int a, int b)
  {
    this.user = user;
    this.jointAType = a;
    this.jointBType = b;
    this.jointAPos = new PVector();
    this.jointBPos = new PVector();
  }
  
  void updatePosition(SimpleOpenNI context)
  {
    float confidenceA = context.getJointPositionSkeleton(this.user, this.jointAType, this.jointAPos);
    float confidenceB = context.getJointPositionSkeleton(this.user, this.jointBType, this.jointBPos);
  }
  
  float distanceToPoint(PVector p)
  {
    // TODO: implement this correctly
    return min(PVector.dist(this.jointAPos, p), PVector.dist(this.jointBPos, p));
  }
}

class Torso extends Bone
{
  Torso(int user, int a, int b)
  {
    super(user, a, b);
  }
}

