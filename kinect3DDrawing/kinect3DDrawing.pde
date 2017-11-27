import SimpleOpenNI.*;
import toxi.geom.*;
import java.util.List;
import java.util.Iterator;
SimpleOpenNI context;

float zoomF = 0.35;
float rotX  = PI;
float rotY  = 0;

public float   xmin = -1000;
public float   xmax = 1000;
public float   ymin = -1000;
public float   ymax = 1000;
public float   zmin = -1000;
public float   zmax = 1000;
public int     resolution = 2;
public int     pixelSize = resolution;

public boolean follow =  true;
public boolean sandEffect = false;
public boolean track = false;


Particles      par;
ArrayList      particlesList = new ArrayList();
public boolean drawBalls = true;
public boolean drawSculpture = true;
public boolean drawPixels = true;
public boolean realColor = true;
ArrayList      balls = new ArrayList();
Ball           sph = new Ball(new PVector(0,0,2000),new PVector(0,0,0),100);

Spline3D       splinePoints = new Spline3D();

void setup(){
  size(1024, 768, P3D);
  frameRate(60);
  perspective(radians(45),float(width)/float(height),10.0,150000.0);
  
  context = new SimpleOpenNI(this);
  context.setMirror(true);
  context.enableDepth();
  context.enableRGB();
  context.alternativeViewPointDepthToImage();
  context.enableHand();
  context.startGesture(SimpleOpenNI.GESTURE_WAVE);
  calculateLimits(context.depthMap(), context.depthMapRealWorld());
  context.update();

}

void draw(){
  context.update();
  int[] depthMap = context.depthMap();
  PVector[] realWorldMap = context.depthMapRealWorld();
  PImage rgbImage = context.rgbImage();

  int[] resDepth = resizeDepth(depthMap,resolution);
  PVector[]resMap3D = resizeMap3D(realWorldMap,resolution);
  PImage resRGB = resizeRGB(rgbImage,resolution);
  boolean[] constrainedImg = constrainImg(resDepth,resMap3D,xmin,xmax,ymin,ymax,zmin,zmax);
  int resXsize = context.depthWidth()/resolution;
  int resYsize = context.depthHeight()/resolution;
  
  background(10);
  translate(width/2,height/2,0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);
  translate(0,0,-1500);
  //drawFloor(color(150),xmin,xmax,ymin,ymax,zmin,zmax);
  //drawGrid(color(255),xmin,xmax,ymin,ymax,zmin,zmax);
  directionalLight(255,255,255,0,-0.2,1); 
  
  
  if(drawPixels){
    par = new Particles(resMap3D,resRGB,constrainedImg);
    //connectedLine = new ConnectedLines(resMap3D,constrainedImg,resXsize,resYsize);
    if(realColor){
      par.paint(pixelSize);
      //connectedLine.paint(color(200));
    }
    else{
      par.paint(pixelSize,color(200));
      //connectedLine.paint(color(200));
    }

    if(follow){
      particlesList.add(par);
      if(sandEffect){
        for(int i = 0; i < particlesList.size()-1; i++){
          par = (Particles) particlesList.get(i);
          par.paint(pixelSize,color(200));
          par.update(ymin);
        }
        if(particlesList.size() > 30){
          particlesList.remove(0);
        }
      } 
      else{
        if(particlesList.size() > 30){
          Particles par1 = (Particles) particlesList.get(15);
          Particles par2 = (Particles) particlesList.get(0);
          if(realColor){
            par1.paint(pixelSize);
            par2.paint(pixelSize);
          }
          else{
            par1.paint(pixelSize,color(200));
            par2.paint(pixelSize,color(200));
          }
          particlesList.remove(0);
        }
      }
    }
    else{
      particlesList.clear();
    }
  }
  
  if(splinePoints.getPointList().size() > 2){
    splinePoints.setTightness(0.25);
    List vertices = splinePoints.computeVertices(4);
    for(int i = 0; i < vertices.size()-2; i++){
      Vec3D p1 = (Vec3D) vertices.get(i);
      Vec3D p2 = (Vec3D) vertices.get(i+1);
      Vec3D p3 = (Vec3D) vertices.get(i+2);
      float rad1 = 60; // + 20*noise(float(i)*0.1);
      float rad2 = 60; // + 20*noise((float(i)+0.5)*0.1);
      float rad3 = 60; // + 20*noise(float(i+1)*0.1);
      color col = color(255);
      float frac = 0.2;
      cilinder(p1,p2,rad1,rad2,col,frac);
      connector(p1,p2,p3,rad2,rad3,col,frac);
    }
  }
  
}

void onNewHand(SimpleOpenNI curContext,int handId,PVector pos){
  println("onNewHand - handId: " + handId + ", pos: " + pos);
  if(drawSculpture && (splinePoints.getPointList().size() == 0)){
    track = true;
  }
}

void onTrackedHand(SimpleOpenNI curContext,int handId,PVector pos){
  if(track){
    splinePoints.add(new Vec3D(pos.x,pos.y,pos.z));
  }
  if(drawBalls){
    float velMag = random(50,80);
    float ang1 = random(0,TWO_PI);
    float ang2 = random(0,HALF_PI/3);
    PVector vel = new PVector(velMag*cos(ang1)*sin(ang2),velMag*cos(ang2),velMag*sin(ang1)*sin(ang2));
    balls.add(new Ball(PVector.add(pos,new PVector(0,50,0)),vel,30));
  }
}

void onLostHand(SimpleOpenNI curContext,int handId){
  track = false;
}

void onCompletedGesture(SimpleOpenNI curContext,int gestureType, PVector pos){
  println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);
  int handId = context.startTrackingHand(pos);
  println("hand stracked: " + handId);
}


