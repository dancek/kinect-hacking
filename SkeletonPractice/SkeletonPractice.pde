/* --------------------------------------------------------------------------
 * SimpleOpenNI User3d Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
 * date:  02/16/2011 (m/d/y)
 * ----------------------------------------------------------------------------
 * this demos is at the moment only for 1 user, will be implemented later
 * ----------------------------------------------------------------------------
 */
import processing.opengl.*;
import SimpleOpenNI.*;
import peasy.*;

// save data as PCD every n milliseconds (-1 to disable)
int          savePcdInterval  = -1;
String       savePcdDirectory = "/home/dance/dev/data/raw";

// read recording from...
String       recordingName    = null;

PeasyCam cam;
SimpleOpenNI context;
PcdWriter pcd;

float        zoomF =0.5f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
                                   // the data from openni comes upside down
float        rotY = radians(0);
boolean      autoCalib=true;
boolean      drawCloud=true;

PVector      bodyCenter = new PVector();
PVector      bodyDir = new PVector();

color[]      userColors = { color(255,0,0), color(0,255,0), color(0,0,255), color(255,255,0), color(255,0,255), color(0,255,255) };

ArrayList bones;
ArrayList boneColors;

Cylinder cyl;

void setup()
{
  size(1600,1080,OPENGL);  // strange, get drawing error in the cameraFrustum if i use P3D, in opengl there is no problem
  cam = new PeasyCam(this, 0,0,-1000, 1500);
  context = new SimpleOpenNI(this);
  pcd = new PcdWriter(context, savePcdDirectory, savePcdInterval);
  
  if (recordingName != null && context.openFileRecording(recordingName) == false)
  {
    println("can't find recording !!!!");
    exit();
  }
   
  // disable mirror
  context.setMirror(false);

  // enable depthMap and RGB image generation 
  if(!context.enableDepth() || !context.enableRGB() || !context.alternativeViewPointDepthToImage())
  {
     println("Something went wrong, maybe the camera is not connected!"); 
     exit();
     return;
  }
  
  println("Depth image size: " + context.depthWidth() + "x" + context.depthHeight());

  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  stroke(255,255,255);
  smooth();  
  perspective(radians(45),
              float(width)/float(height),
              10,150000);
              
  cyl = new Cylinder(20, 20);

  bones = new ArrayList();
  createBones(1);
  
  colorMode(HSB, bones.size(), 255, 255);
  boneColors = new ArrayList();
  for (int i=0; i < bones.size(); ++i) {
    boneColors.add(color(i, 255, 255));
  }
  colorMode(RGB, 255);
}

void draw()
{
  // update the cam
  context.update();

  background(0,0,0);
  
  // set the scene pos
  //translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);
  
  int[]   depthMap = context.depthMap();
  int     steps    = 2;  // to speed up the drawing, draw every nth point
  int     index;
  boolean trackingSkeleton = false;
  PVector realWorldPoint;

  PImage  rgbImage = context.rgbImage();
  rgbImage.loadPixels();

  int userCount = context.getNumberOfUsers();
  int[] userMap = null;
  if(userCount > 0)
  {
    userMap = context.getUsersPixels(SimpleOpenNI.USERS_ALL);
    for (int u=1; u<=userCount; ++u) {
      if (context.isTrackingSkeleton(u)) {
        trackingSkeleton = true;
        Bone bone;
        for (int i=0; i < bones.size(); ++i) {
          bone = (Bone) bones.get(i);
          bone.updatePosition(context);
        }
      }
    }
  }
  
  // tell PcdWriter about a new frame
  pcd.beginFrame(millis(), trackingSkeleton);

  stroke(100); 
  for(int y=0;y < context.depthHeight();y+=steps)
  {
    for(int x=0;x < context.depthWidth();x+=steps)
    {
      index = x + y * context.depthWidth();
      if(depthMap[index] > 0)
      { 
        realWorldPoint = context.depthMapRealWorld()[index];

        // check if there is a user
        if(userMap != null && userMap[index] != 0)
        {
          int pointType;
          if (context.isTrackingSkeleton(userMap[index])) {
            // find the closest bone
            int colorIndex = 0;
            float closestDistance = Float.MAX_VALUE, distance;
            Bone bone, closestBone = null;
            for (int i=0; i < bones.size(); ++i) {
              bone = (Bone) bones.get(i);
              // check distance
              distance = bone.distanceToPoint(realWorldPoint);
              if (distance < closestDistance) {
                colorIndex = i;
                closestDistance = distance;
                closestBone = bone;
              }
            }
            // assign the point to the bone
            closestBone.addPoint(realWorldPoint, closestDistance, rgbImage.pixels[index]);
            // choose color
            stroke((Integer) boneColors.get(colorIndex));
            pointType = colorIndex;
          } else {
            int colorIndex = userMap[index] % userColors.length;
            stroke(userColors[colorIndex]);
            pointType = -colorIndex;
          }
          // tell PcdWriter about this user point
          pcd.addPoint(realWorldPoint, rgbImage.pixels[index], pointType);
        }
        else
          stroke(rgbImage.pixels[index]); 

        if (drawCloud) {
          // draw the projected point
          point(realWorldPoint.x,realWorldPoint.y,realWorldPoint.z);
        }
      }
    } 
  } 
  
  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    if(context.isTrackingSkeleton(userList[i]))
    {
      drawSkeleton(userList[i]);
    }
  }    
 
  // draw the kinect cam
  context.drawCamFrustum();
  
  pcd.endFrame();
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  lights();
  
  Bone bone;
  for (int i=0; i<bones.size(); ++i) {
    bone = (Bone) bones.get(i);
    bone.draw();
  }
}

// TODO: use this
void drawJointOrientation(int userId,int jointType,PVector pos,float length)
{
  // draw the joint orientation  
  PMatrix3D  orientation = new PMatrix3D();
  float confidence = context.getJointOrientationSkeleton(userId,jointType,orientation);
  if(confidence < 0.001f) 
    // nothing to draw, orientation data is useless
    return;
    
  pushMatrix();
    translate(pos.x,pos.y,pos.z);
    
    // set the local coordsys
    applyMatrix(orientation);
    
    // coordsys lines are 100mm long
    // x - r
    stroke(255,0,0,confidence * 200 + 55);
    line(0,0,0,
         length,0,0);
    // y - g
    stroke(0,255,0,confidence * 200 + 55);
    line(0,0,0,
         0,length,0);
    // z - b    
    stroke(0,0,255,confidence * 200 + 55);
    line(0,0,0,
         0,0,length);
  popMatrix();
}

// -----------------------------------------------------------------
// SimpleOpenNI user events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");
  
  if(autoCalib)
    context.requestCalibrationSkeleton(userId,true);
  else    
    context.startPoseDetection("Psi",userId);
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}

void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
}

void onReEnterUser(int userId)
{
  println("onReEnterUser - userId: " + userId);
}


void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  
  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId); 
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi",userId);
  }
}

void onStartPose(String pose,int userId)
{
  println("onStartdPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");
  
  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
 
}

void onEndPose(String pose,int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

// -----------------------------------------------------------------
// Keyboard events

void keyPressed()
{
  switch(key)
  {
  case ' ':
    // toggle drawing point cloud
    drawCloud = !drawCloud;
    break;
  }
    
  switch(keyCode)
  {
    case LEFT:
      rotY += 0.1f;
      break;
    case RIGHT:
      // zoom out
      rotY -= 0.1f;
      break;
    case UP:
      if(keyEvent.isShiftDown())
        zoomF += 0.01f;
      else
        rotX += 0.1f;
      break;
    case DOWN:
      if(keyEvent.isShiftDown())
      {
        zoomF -= 0.01f;
        if(zoomF < 0.01)
          zoomF = 0.01;
      }
      else
        rotX -= 0.1f;
      break;
  }
}

// TODO: use this
void getBodyDirection(int userId,PVector centerPoint,PVector dir)
{
  PVector jointL = new PVector();
  PVector jointH = new PVector();
  PVector jointR = new PVector();
  float  confidence;
  
  // draw the joint position
  confidence = context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_SHOULDER,jointL);
  confidence = context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_HEAD,jointH);
  confidence = context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER,jointR);
  
  // take the neck as the center point
  confidence = context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,centerPoint);
  
  /*  // manually calc the centerPoint
  PVector shoulderDist = PVector.sub(jointL,jointR);
  centerPoint.set(PVector.mult(shoulderDist,.5));
  centerPoint.add(jointR);
  */
  
  PVector up = new PVector();
  PVector left = new PVector();
  
  up.set(PVector.sub(jointH,centerPoint));
  left.set(PVector.sub(jointR,centerPoint));
  
  dir.set(up.cross(left));
  dir.normalize();
}

void createBones(int userId)
{
  bones.add(new Bone(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK));

  bones.add(new Bone(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER));
  bones.add(new Bone(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW));
  bones.add(new Bone(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND));

  bones.add(new Bone(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER));
  bones.add(new Bone(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW));
  bones.add(new Bone(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND));

  bones.add(new Bone(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_TORSO));

  bones.add(new Bone(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP));
  bones.add(new Bone(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE));
  bones.add(new Bone(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT));

  bones.add(new Bone(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP));
  bones.add(new Bone(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE));
  bones.add(new Bone(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT)); 
}
