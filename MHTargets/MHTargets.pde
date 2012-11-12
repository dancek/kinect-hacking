/*
    Reimplemented MakeHuman target system
    Copyright (C) 2012 Hannu Hartikainen

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import java.io.File;
import processing.opengl.*;
import controlP5.*;
import peasy.*;
import saito.objloader.*;

// configuration
String mhpath = "/home/dance/dev/makehuman";
String targetpath = mhpath + "/data/targets/measure/";
String basemeshpath = "/home/dance/makehuman/data/clean_base.obj";

ControlP5 cp5;
ControlWindow controlWindow;
OBJModel human;
PeasyCam cam;

ArrayList targets;
Target target;
float sliderValue;
TargetSlider ts;

void setup()
{
  size(1024,768,OPENGL);
  
  targets = new ArrayList();
  cp5 = new ControlP5(this);
  cam = new PeasyCam(this, 500);
  human = new OBJModel(this, basemeshpath, QUAD);

  human.disableMaterial();

  controlWindow = cp5.addControlWindow("controlP5window", 30, 30, 320, 600)
    .hideCoordinates().setBackground(color(40));

  int i = 0;
  File dir = new File(targetpath);
  for (File f : dir.listFiles())
  {
    ts = new TargetSlider(cp5, controlWindow, i++, f.getAbsolutePath(), human);
    targets.add(ts);
  }
}

void draw()
{
  for (Object t : targets) {
    ((TargetSlider) t).update();
  }
  
  background(0);
  lights();
  noStroke();
  fill(127);

  specular(1,1,1);

  pushMatrix();
  scale(20);
  human.draw();
  popMatrix();
}

