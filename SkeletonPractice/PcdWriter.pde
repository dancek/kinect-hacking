/**
 * Export point cloud in PCD format
 */

class PcdWriter
{
  int interval;
  int savedFrames;
  
  boolean saveFrame;
  
  FileWriter fw;
  
  PcdWriter(int intervalMillis)
  {
    this.interval = intervalMillis;
    this.savedFrames = 0;
    this.saveFrame = false;
  }
  
  /**
   * Start a new frame. Check if the interval has passed and the frame should be saved.
   */
  boolean beginFrame(int elapsedMillis)
  {
    if (this.interval > 0 && elapsedMillis / this.interval > this.savedFrames) {
      try {
        this.fw = new FileWriter("cloud.pcd");
      } catch (IOException e) {
        return false;
      }
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
    this.savedFrames += 1;
    this.saveFrame = false;
    try {
      this.fw.close();
    } catch (IOException e) {
      return false;
    }
    return true;
  }
  
  /**
   * Add a point to the point cloud.
   */
  void addPoint(PVector p, color c)
  {
    if (!this.saveFrame) {
      return;
    }
    try {
      this.fw.write(p.x + " " + p.y + " " + p.z + " " + c + "\n");
    } catch (IOException e) {
      // TODO
    }
  }
}
