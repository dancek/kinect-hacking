import java.io.BufferedReader;
import java.io.FileReader;

class Target
{
  private HashMap translations;
  private float wdiff;
  private float weight;
  
  public Target(String filename)
  {
    translations = new HashMap();
    
    try {
      BufferedReader br = new BufferedReader(new FileReader(filename));
      
      String cur = "";
      while (null != (cur = br.readLine()))
      {
        String[] parts = cur.split(" ");

        int i = Integer.parseInt(parts[0]);
        float x = Float.parseFloat(parts[1]);
        float y = Float.parseFloat(parts[2]);
        float z = Float.parseFloat(parts[3]);

        PVector v = new PVector(x,y,z);
        translations.put(i, v);
      }
      
      br.close();
    } catch (IOException e) {
      /* TODO */
    }
  }
  
  public void apply(OBJModel mesh)
  {
    if (this.wdiff == 0.0)
      return;
    for (Iterator it = translations.entrySet().iterator(); it.hasNext();)
    {
      Map.Entry pair = (Map.Entry) it.next();
      int i = (Integer) pair.getKey();
      PVector v = mesh.getVertex(i);

      PVector translation = new PVector();
      translation.set((PVector) pair.getValue());
      translation.mult(this.wdiff);
      v.add(translation);      
    }
  }
  
  public boolean setWeight(float w)
  {
    this.wdiff = w - this.weight;
    this.weight = w;
    return this.wdiff != 0.0;
  }
}
