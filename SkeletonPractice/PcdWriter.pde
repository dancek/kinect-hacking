/**
 * Export point cloud in PCD format
 */

class PcdWriter
{
  SimpleOpenNI context;
  
  int interval;
  int savedFrames;
  
  boolean saveFrame;
  
  ArrayList points;
  
  String directory;
  FileWriter fw;
  
  PcdWriter(SimpleOpenNI context, String directory, int intervalMillis)
  {
    this.context = context;
    this.directory = directory;
    this.interval = intervalMillis;
    this.savedFrames = 0;
    this.saveFrame = false;
    this.points = new ArrayList();
  }
  
  /**
   * Start a new frame. Check if the interval has passed and the frame should be saved.
   */
  boolean beginFrame(int elapsedMillis)
  {
    if (this.interval > 0 && elapsedMillis / this.interval > this.savedFrames) {
      this.saveFrame = true;
      return true;
    }
    return false;
  }
  
  /**
   * Inform PcdWriter that all frame data has been input.
   */
  boolean endFrame()
  {
    if (!this.saveFrame) {
      return false;
    }
    this.writePcd();
    this.points.clear();
    this.savedFrames += 1;
    this.saveFrame = false;
    return true;
  }
  
  /**
   * Add a point to the point cloud.
   */
  void addPoint(PVector p, color c, int type)
  {
    if (!this.saveFrame) {
      return;
    }
    this.points.add(new PcdPoint(p,c,type));
  }
  
  private void writePcd()
  {
    DateFormat df = new SimpleDateFormat("yyyy-MM-dd_HHmmss.SSSS");
    String filename = this.directory + "/" + df.format(new Date()) + ".pcd";
    try {
      // open file
      this.fw = new FileWriter(filename);
      
      this.writeSkeletonInfo();
      
      // write header
      this.fw.write("VERSION .7\n");
      this.fw.write("FIELDS x y z rgb type\n");
      this.fw.write("SIZE 4 4 4 4 4\n");
      this.fw.write("TYPE F F F I I\n");
      this.fw.write("COUNT 1 1 1 1 1\n");
      this.fw.write("WIDTH " + this.points.size() + "\n");
      this.fw.write("HEIGHT 1\n");
      this.fw.write("VIEWPOINT 0 0 0 1 0 0 0\n");
      this.fw.write("POINTS " + this.points.size() + "\n");
      this.fw.write("DATA ascii\n");
      
      // write data
      PcdPoint p;
      for (int i = 0; i < this.points.size(); ++i) {
        p = (PcdPoint) this.points.get(i);
        this.fw.write(p + "\n");
      }
      
      // close stream
      this.fw.close();
    } catch (IOException e) {
      // TODO
    }
  }
  
  private void writeSkeletonInfo() throws IOException
  {
    for (int u = 1; u <= context.getNumberOfUsers(); ++u) {
      if (context.isTrackingSkeleton(u)) {
        this.fw.write("# user " + u);
        this.fw.write("# head "           + this.getJointString(u, SimpleOpenNI.SKEL_HEAD) + "\n");
        this.fw.write("# neck "           + this.getJointString(u, SimpleOpenNI.SKEL_NECK) + "\n");
        this.fw.write("# torso "          + this.getJointString(u, SimpleOpenNI.SKEL_TORSO) + "\n");
        this.fw.write("# left_shoulder "  + this.getJointString(u, SimpleOpenNI.SKEL_LEFT_SHOULDER) + "\n");
        this.fw.write("# left_elbow "     + this.getJointString(u, SimpleOpenNI.SKEL_LEFT_ELBOW) + "\n");
        this.fw.write("# left_hand "      + this.getJointString(u, SimpleOpenNI.SKEL_LEFT_HAND) + "\n");
        this.fw.write("# right_shoulder " + this.getJointString(u, SimpleOpenNI.SKEL_RIGHT_SHOULDER) + "\n");
        this.fw.write("# right_elbow "    + this.getJointString(u, SimpleOpenNI.SKEL_RIGHT_ELBOW) + "\n");
        this.fw.write("# right_hand "     + this.getJointString(u, SimpleOpenNI.SKEL_RIGHT_HAND) + "\n");
        this.fw.write("# left_hip "       + this.getJointString(u, SimpleOpenNI.SKEL_LEFT_HIP) + "\n");
        this.fw.write("# left_knee "      + this.getJointString(u, SimpleOpenNI.SKEL_LEFT_KNEE) + "\n");
        this.fw.write("# left_foot "      + this.getJointString(u, SimpleOpenNI.SKEL_LEFT_FOOT) + "\n");
        this.fw.write("# right_hip "      + this.getJointString(u, SimpleOpenNI.SKEL_RIGHT_HIP) + "\n");
        this.fw.write("# right_knee "     + this.getJointString(u, SimpleOpenNI.SKEL_RIGHT_KNEE) + "\n");
        this.fw.write("# right_foot "     + this.getJointString(u, SimpleOpenNI.SKEL_RIGHT_FOOT) + "\n");
      }
    }
  }
  
  private String getJointString(int user, int jointType)
  {
    // TODO: write orientation!
    PVector p = null;
    float confidence = context.getJointPositionSkeleton(user, jointType, p);
    return p.x + " " + p.y + " " + p.z + " " + confidence;
  }

  private class PcdPoint
  {
    PVector p;
    int c;
    int t;
    
    PcdPoint(PVector p, color c, int t)
    {
      this.p = p;
      this.t = t;
      /* PCD supports color as ARGB uint32_t. Processing also uses 32-bit ARGB
      but interprets ints as signed. Therefore we need to reinterpret the color
      as unsigned. Throwing the alpha channel away is the easiest way :) */
      this.c = c & 0xffffff;
    }
    
    String toString()
    {
      return p.x + " " + p.y + " " + p.z + " " + c + " " + t;
    }
  }
}
