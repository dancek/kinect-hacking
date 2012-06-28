import SimpleOpenNI.*;

SimpleOpenNI  context;

int RECTSIZE = 20;

void setup()
{
  context = new SimpleOpenNI(this);
  context.enableDepth();
  context.enableRGB();
  size(800,480);
}

void draw()
{
  context.update();
  background(0,0,0);
  colorMode(RGB);
  
  PImage img = context.rgbImage();
  img.loadPixels();
  image(img, 0, 0);
  
  stroke(255,255,255,95);
  noFill();
  rectMode(CENTER);
  rect(mouseX, mouseY, 2*RECTSIZE, 2*RECTSIZE);
  
  int count = 0;
  float r=0, g=0, b=0, h=0, s=0, l=0;
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
    }
  }
  noStroke();
  rectMode(CORNER);
  fill(color(r/count, g/count, b/count));
  rect(640,0,160,160);
  colorMode(HSB);
  fill(color(h/count, s/count, l/count));
  rect(640,160,160,160);
}
