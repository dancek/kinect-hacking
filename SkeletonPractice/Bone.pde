class Bone
{
  int endA;
  int endB;
  int user;
  
  Bone(int user, int a, int b)
  {
    this.user = user;
    this.endA = a;
    this.endB = b;
  }
}

class Torso extends Bone
{
  Torso(int user, int a, int b)
  {
    super(user, a, b);
  }
}

