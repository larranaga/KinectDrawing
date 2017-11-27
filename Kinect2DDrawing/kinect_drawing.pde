import org.openkinect.freenect.*;
import org.openkinect.processing.*;

Kinect kinect;

float deg;

boolean ir = false;
boolean colorDepth = false;
boolean mirror = true;
boolean defaultBackground = true;

PGraphics pg;

PImage clearBackground;
PImage loadBackground;
PImage saveBackground;

PImage scene;
PImage sceneI;

averagePoint avg;

float x, y;

float resetminx = 2, resetminy = 2;
float resetmaxx = 130, resetmaxy = 59;

float backgroundminx =  2, backgroundminy =  70;
float backgroundmaxx = 130, backgroundmaxy = 59;

float saveminx =  2, saveminy =  138;
float savemaxx = 130, savemaxy = 59;

int nscreenshot = 0;
float ycp =0;
float circleRadius = 30;

void setup() {
  size(640, 480, P3D);
  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.initVideo();
  //kinect.enableIR(ir);
  kinect.enableColorDepth(colorDepth);
  kinect.enableMirror(mirror);

  deg = kinect.getTilt();
  // kinect.tilt(deg);
  
  pg =createGraphics(640, 480);
  clearBackground =  loadImage("clear.png");
  loadBackground =  loadImage("Background.png");
  saveBackground =  loadImage("save.png");
  sceneI = loadImage("scene.png");
   
}

void draw() {
  int[] depth = kinect.getRawDepth();
  avg = new averagePoint(depth, kinect.width, kinect.height);
  //System.out.println(avg.toString());
  float avgX = avg.getX();
  float avgY = avg.getY();  
  //buttons.box(100);
 
  pg.beginDraw();
  //pg.rect(resetminx,resetminy,resetmaxx,resetmaxy);
  pg.image(clearBackground, resetminx, resetminy, resetmaxx, resetmaxy);
  pg.image(loadBackground, backgroundminx, backgroundminy, backgroundmaxx, backgroundmaxy);
  pg.image(saveBackground, saveminx, saveminy, savemaxx, savemaxy);
    
  for (int i = 2; i < 10; i+=2) {
    pg.strokeWeight(i*2);
    pg.stroke(255,0,0);
    pg.line(avgX, avgY, x, y);
  }
  
  for(int i = 0; i <= 1; ++i){
    float xcp = random(500) + 130;
    float rc = random(255);
    float gc = random(255);
    float bc = random(255);
    //float yspeed = 1.2;
    pg.noStroke();
    for(int j = 0; j <= 480; ++j){
       pg.fill(rc, gc, bc);
       //ycp = ycp + (1 * yspeed);
       ycp += 0.2;
       pg.ellipse(xcp, ycp, circleRadius, circleRadius);
    }
  }
  pg.noFill();
  
  pg.endDraw();
  
  x = avgX;
  y = avgY;
  
  if(x <= resetmaxx && y <= resetmaxy && x >= resetminx && y >= resetminy){
      pg.clear();
   }
  
 // System.out.printf("x = %f y = %f\n", avgX, avgY);
 if(x <= backgroundmaxx && y <= backgroundmaxy + 70 && x >= backgroundminx && y >= backgroundminy){
      defaultBackground = !defaultBackground;
 } 
 
 if(x <= savemaxx && y <= savemaxy + 138 && x >= saveminx && y >= saveminy){
   image(scene, 0, 0);
   image(pg,0,0);
   save("screenshot.png");
   /*save("screenshot_"+ nscreenshot +".png");
   nscreenshot++;*/
 }

 
  
  //background(0);
  if(defaultBackground){
    scene = kinect.getVideoImage();
    image(scene, 0, 0);
    image(pg, 0, 0);
  }
  else{
    image(sceneI,0,0);
    image(pg, 0, 0);
    
    //user 
    /*
    if (kinect.getNumberOfUsers() > 0) {
    PImage rgbImage = kinect.rgbImage();
    
    rgbImage.loadPixels();
    loadPixels();
    
    userMap = kinect.userMap();
    for( int i = 0; i < userMap.length; i++){
      //If pixel belongs to a person change the frames pixel with corresponding rgb-pixel
      if (userMap[i] != 0) {
        pixels[i] = rgbImage.pixels[i];
      }
    }
    updatePixels();
  }*/
  }
  
  
  //image(kinect.getDepthImage(), 640, 0);
  fill(255);
  text(
    "Press 'i' to enable/disable between video image and IR image,  " +
    "Press 'c' to enable/disable between color depth and gray scale depth,  " +
    "Press 'm' to enable/diable mirror mode, "+
    "UP and DOWN to tilt camera   " +
    "Framerate: " + int(frameRate), 10, 515);
}

void keyPressed() {
  if(key == 'w'){
    avg.maxThresh += 5;
  }
  if(key == 's'){
    avg.maxThresh -= 5;
  }
  if(key == 'a'){
    avg.minThresh -= 5;
  }
  if(key == 'd'){
    avg.minThresh += 5;
  }
  if (key == 'i') {
    ir = !ir;
    kinect.enableIR(ir);
  } else if (key == 'c') {
    colorDepth = !colorDepth;
    kinect.enableColorDepth(colorDepth);
  }else if(key == 'm'){
    mirror = !mirror;
    kinect.enableMirror(mirror);
  } else if (key == CODED) {
    if (keyCode == UP) {
      deg++;
    } else if (keyCode == DOWN) {
      deg--;
    }
    deg = constrain(deg, 0, 30);
    kinect.setTilt(deg);
  }
}