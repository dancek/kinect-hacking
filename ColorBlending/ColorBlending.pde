/**
 * Show the average color inside a box that follows mouse.
 * The averaging is done in RGB, HSB and CIELab (in order).
 */
import SimpleOpenNI.*;

SimpleOpenNI  context;
CIELab labConverter;

int RECTSIZE = 20;

void setup()
{
  labConverter = CIELab.getInstance();
  context = new SimpleOpenNI(this);
  context.enableDepth();
  context.enableRGB();
  size(800,480);
  colorMode(RGB, 1.0, 1.0, 1.0);
}

void draw()
{
  context.update();
  background(0,0,0);
  
  PImage img = context.rgbImage();
  img.loadPixels();
  image(img, 0, 0);
  
  stroke(255,255,255,95);
  noFill();
  rectMode(CENTER);
  rect(mouseX, mouseY, 2*RECTSIZE, 2*RECTSIZE);
  
  int count = 0;
  float r=0, g=0, b=0, h=0, s=0, l=0, labL=0, labA=0, labB=0;
  float[] lab = {0,0,0};
  color c;
  for (int x=mouseX-RECTSIZE; x<=mouseX+RECTSIZE; ++x) {
    for (int y=mouseY-RECTSIZE; y<=mouseY+RECTSIZE; ++y) {
      if (x<0 || y<0 || x>=640 || y>=480) {
        continue;
      }
      count++;
      c = img.pixels[y * 640 + x];
      r += red(c);
      g += green(c);
      b += blue(c);
      h += hue(c);
      s += saturation(c);
      l += brightness(c);
      
      float rgb[] = {red(c), green(c), blue(c)};
      lab = labConverter.fromRGB(rgb);
      labL += lab[0];
      labA += lab[1];
      labB += lab[2];
    }
  }
  
  noStroke();
  rectMode(CORNER);
  fill(color(r/count, g/count, b/count));
  rect(640,0,160,160);
  
  colorMode(HSB);
  fill(color(h/count, s/count, l/count));
  rect(640,160,160,160);
  colorMode(RGB, 1.0, 1.0, 1.0);
  
  lab[0] = labL / count;
  lab[1] = labA / count;
  lab[2] = labB / count;
  float[] rgb = labConverter.toRGB(lab);
  fill(color(rgb[0], rgb[1], rgb[2]));
  rect(640,320,160,160);
}
