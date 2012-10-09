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

import processing.opengl.*;
import controlP5.*;
import peasy.*;
import saito.objloader.*;

// configuration
String mhpath = "/home/dance/dev/makehuman";
String targetpath = mhpath + "/data/targets/measure/measure-neckheight-increase.target";
String basemeshpath = mhpath + "/data/3dobjs/base.obj";

ControlP5 cp5;
OBJModel human;
PeasyCam cam;

Target target;
float sliderValue;

void setup()
{
  size(1024,768,OPENGL);
  
  cp5 = new ControlP5(this);
  cam = new PeasyCam(this, 500);
  human = new OBJModel(this, basemeshpath, QUAD);

  human.disableMaterial();

  // add a horizontal sliders, the value of this slider will be linked
  // to variable 'sliderValue' 
  cp5.addSlider("sliderValue")
     .setPosition(10,10)
     .setRange(-1.0, 1.0)
     ;
  cp5.setAutoDraw(false);
  
  target = new Target(targetpath);
}

void draw()
{
  target.setWeight(sliderValue);
  target.apply(human);
  
  background(0);
  lights();
  noStroke();
  fill(127);

  pushMatrix();
  scale(20);
  human.draw();
  popMatrix();
  
  gui();
}

void gui() {
  cam.beginHUD();
  cp5.draw();
  cam.endHUD();
}

