class TargetSlider
{
  private final float MINVAL = -1.0;
  private final float MAXVAL = 1.0;
  private final float DEFVAL = 0.0;
  private final int X = 10;
  private final int Y = 10;
  private final int YSTEP = 12;
  private final int W = 150;
  private final int H = 8;
  
  private Slider s;
  private Target t;
  private OBJModel m;
  
  public TargetSlider(ControlP5 cp, ControlWindow win, int idx, String filename, OBJModel mesh)
  {
    String name = filename.replaceFirst("/.*/", "").replaceFirst(".target$", "");
    s = new Slider(cp, null, name, MINVAL, MAXVAL, DEFVAL, X, Y+idx*YSTEP, W, H);
    s.setWindow(win);
    t = new Target(filename);
    m = mesh;
  }
  
  public void update()
  {
    float val = s.getValue();
    t.setWeight(val);
    t.apply(m);
  }
}
