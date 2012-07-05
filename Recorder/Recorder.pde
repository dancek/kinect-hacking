import SimpleOpenNI.*;

SimpleOpenNI  context;

// where to save the recording
String        outputFilename = "/tmp/test.oni";

void setup()
{
  context = new SimpleOpenNI(this);

  // recording
  // enable depthMap generation 
  if (context.enableDepth() == false)
  {
    println("Can't open the depthMap, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // enable ir generation
  if (context.enableRGB() == false)
  {
    println("Can't open the rgbMap, maybe the camera is not connected or there is no rgbSensor!"); 
    exit();
    return;
  }

  context.alternativeViewPointDepthToImage();
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  
  // setup the recording 
  context.enableRecorder(SimpleOpenNI.RECORD_MEDIUM_FILE, outputFilename);

  // select the recording channels
  context.addNodeToRecording(SimpleOpenNI.NODE_DEPTH, SimpleOpenNI.CODEC_16Z_EMB_TABLES);
  context.addNodeToRecording(SimpleOpenNI.NODE_IMAGE, SimpleOpenNI.CODEC_JPEG);
  context.addNodeToRecording(SimpleOpenNI.NODE_USER, SimpleOpenNI.CODEC_16Z_EMB_TABLES);

  // set window size 
  if ((context.nodes() & SimpleOpenNI.NODE_DEPTH) != 0)
  {
    if ((context.nodes() & SimpleOpenNI.NODE_IMAGE) != 0)
      // depth + rgb 
      size(context.depthWidth() + 10 +  context.rgbWidth(), 
      context.depthHeight() > context.rgbHeight()? context.depthHeight():context.rgbHeight());   
    else
      // only depth
      size(context.depthWidth(), context.depthHeight());
  }
  else 
    exit();
}

void draw()
{
  // update
  context.update(); 

  background(200, 0, 0);

  // draw the cam data
  if ((context.nodes() & SimpleOpenNI.NODE_DEPTH) != 0)
  {
    if ((context.nodes() & SimpleOpenNI.NODE_IMAGE) != 0)
    {
      image(context.depthImage(), 0, 0);   
      image(context.rgbImage(), context.depthWidth() + 10, 0);
    }
    else
      image(context.depthImage(), 0, 0);
  }

  if ((context.nodes() & SimpleOpenNI.NODE_SCENE) != 0)  
    image(context.sceneImage(), 0, 0, context.sceneWidth()*.4, context.sceneHeight()*.4);
    
}

