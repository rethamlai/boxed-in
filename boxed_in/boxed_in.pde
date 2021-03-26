//Import minim packages
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;
FFT fft;

String audioFilePath = "song.mp3";

// Declare camera zoom variables
float zoomFrom;
float zoomTo;
int   zoomDuration;
int   zoomStart;

// Declare parameters to analyse music
float specLow = 0.03;
float specMid = 0.125;
float specHi = 0.20;

float scoreLow = 0;
float scoreMid = 0;
float scoreHi = 0;

float oldScoreLow = scoreLow;
float oldScoreMid = scoreMid;
float oldScoreHi = scoreHi;

float scoreDecreaseRate = 25;

// Declare small box particles
boxParticle[] bp = new boxParticle[800];
int diagonal;
float rotationX = 0;
float rotationY = 0;
float rotationZ = 0;
float boxDimension = 280;

// Declare lightning strike particles
int noDist;
DistortedLine[] dl;

// Declare sphere object
ArrayList<SphereLoc> spheres = new ArrayList<SphereLoc>();
int noSpheres;
float xSphere = 0;
float ySphere = 0;
float zSphere = 0;
float xSphereSpeed = 1;
float ySphereSpeed = 1;
float zSphereSpeed = 1;

// Declare wall objects
int noWalls = 1650;
Wall[] walls;

// Declare starting background colors
float startR = 0;
float endR = 50;
float startG = 0;
float endG = 5;
float startB = 0;
float endB = 100;

// Seconds to trigger second part
float triggerSecond = 144.533;

void setup() {

  // Set up
  fullScreen(P3D);
  frameRate(60);
  fill(255);
  noStroke();
  strokeWeight(1);
  diagonal = (int)sqrt(width*width + height * height)/2;

  // Set up music player
  minim = new Minim(this);
  song = minim.loadFile(audioFilePath);
  fft = new FFT(song.bufferSize(), song.sampleRate());

  // Set up zoom variables
  zoomFrom = 2.6;
  zoomTo = 0.9;
  zoomDuration = 16000;
  zoomStart = -zoomDuration;

  // Set up box particles
  for (int i = 0; i<bp.length; i++) {
    bp[i] = new boxParticle(boxDimension);
    bp[i].o = random(1, random(1, width/bp[i].n));
  }

  // Set up lightning strikes
  noDist = 1;
  dl = new DistortedLine[noDist];
  for (int i = 0; i < noDist; i++) {
    dl[i] = new DistortedLine();
  }

  // Set up sphere
  noSpheres = 1;
  for (int i=0; i<noSpheres; i++) {
    pushMatrix();  
    fill(0, 255, 255);
    spheres.add(new SphereLoc(random(-boxDimension, boxDimension), 
      random(-boxDimension, boxDimension), 
      random(-boxDimension, boxDimension), 
      5));
    popMatrix();
  }

  // Set up walls
  walls = new Wall[noWalls];

  //Create wall objects first, so they are layered below
  //Left walls
  for (int i = 0; i < noWalls; i+=4) {
    walls[i] = new Wall(0, height/2, height/2, height);
  }

  //Right walls
  for (int i = 1; i < noWalls; i+=4) {
    walls[i] = new Wall(width, height/2, height/2, height);
  }

  //Bottom walls
  for (int i = 2; i < noWalls; i+=4) {
    walls[i] = new Wall(width/2, height, width, 10);
  }

  //Top walls
  for (int i = 3; i < noWalls; i+=4) {
    walls[i] = new Wall(width/2, 0, width, 10);
  }

  // Play song
  song.play(0);
}


void draw() {

  // Set up
  float s = millis();
  // Second drop
  //float zoomSecond = 143.3 ;
  float triggerFlag = 0;
  background(0);
  translate(width/2, height/2, 0);

  // Analyse song
  fft.forward(song.mix);

  // Calculate song ranges
  oldScoreLow = scoreLow;
  oldScoreMid = scoreMid;
  oldScoreHi = scoreHi;

  scoreLow = 0;
  scoreMid = 0;
  scoreHi = 0;

  for (int i = 0; i < fft.specSize()*specLow; i++)
  {
    scoreLow += fft.getBand(i);
  }

  for (int i = (int)(fft.specSize()*specLow); i < fft.specSize()*specMid; i++)
  {
    scoreMid += fft.getBand(i);
  }

  for (int i = (int)(fft.specSize()*specMid); i < fft.specSize()*specHi; i++)
  {
    scoreHi += fft.getBand(i);
  }

  if (oldScoreLow > scoreLow) {
    scoreLow = oldScoreLow - scoreDecreaseRate;
  }

  if (oldScoreMid > scoreMid) {
    scoreMid = oldScoreMid - scoreDecreaseRate;
  }

  if (oldScoreHi > scoreHi) {
    scoreHi = oldScoreHi - scoreDecreaseRate;
  }


  //Change background color to song + randomise color change every so often 
  //Only randomise after zoomSecond
  if (triggerFlag == 0) {
    if (s >= 1000 * triggerSecond) {
      if (s % 5 >= 0 && s % 5 <= 15) {
        startR = random(0, 25);
        endR = random(startR, 135);
        startG = random(0, 25);
        endG = random(startG, 135);
        startB = random(0, 25);
        endB = random(startB, 135);
      }
    }
  }

  background(map(scoreLow, 0, 500, startR, endR), 
    map(scoreMid, 0, 300, startG, endG), 
    map(scoreHi, 0, 150, startB, endB));

  if (s < (triggerSecond * 1000)) {
    float intensityRot = fft.getBand(1);
    if (intensityRot > 1.7) {
      rotationX += 0.003;
      rotationY += 0.003;
      rotationZ += 0.003;
    } else {
      rotationX += 0.0005;
      rotationY += 0.0005;
      rotationZ += 0.0005;
    }
  } else if (s >= (triggerSecond * 1000)) {

    rotationX += 0.0005;
    rotationY += 0.0005;
    rotationZ += 0.0005;
  }
  rotateX(rotationX);
  rotateY(rotationY);
  rotateZ(rotationZ);

  //***********************************//
  //************ First part ***********//
  //***********************************//

  if (s < triggerSecond*1000) {

    // Display box particles   
    for (int i = 0; i < bp.length; i++) {
      pushMatrix();
      float intensity = fft.getBand(i);
      bp[i].display(scoreLow, scoreMid, scoreHi, intensity);
      popMatrix();

      // Display lightning strikes
      if (i > 0) {
        for (int j = 0; j < noDist; j+= 1) {
          pushMatrix();
          strokeWeight(random(1, 3));
          stroke(180, 180, 0, random(0, 255));
          dl[j].display(10, bp[i].x, bp[i].y, bp[i].z, bp[i-1].x, bp[i-1].y, bp[i-1].z);
          popMatrix();
        }
      }

      // If box particles are larger than a specific size, then redraw
      if (bp[i].drawDist() > diagonal) {
        bp[i] = new boxParticle(boxDimension);
      }
    }

    // Display sphere + update location
    for (int t=0; t < spheres.size(); t++) {
      strokeWeight(1);
      spheres.get(0).update(xSphere, ySphere, zSphere);
    }

    // Speed and direction of sphere
    xSphere += xSphereSpeed;
    ySphere += ySphereSpeed;
    zSphere += zSphereSpeed;

    // Give the sphere a chance to escape the cage
    float threshold = random(0, 100);
    for (int i = 0; i < bp.length; i++) {
      if (threshold < 7) {

        if (xSphere < -bp[i].x - bp[i].returnBoxSize() || xSphere > bp[i].x + bp[i].returnBoxSize()) {
          xSphereSpeed *= -1;
        }

        if (ySphere < -bp[i].y - bp[i].returnBoxSize() || ySphere > bp[i].y + bp[i].returnBoxSize()) {
          ySphereSpeed *= -1;
        }

        if (zSphere < -bp[i].z - bp[i].returnBoxSize() || zSphere > bp[i].z + bp[i].returnBoxSize()) {
          zSphereSpeed *= -1;
        }
      }
    }

    // If sphere exits the cage, then move back to cage and show cage
    if (xSphere < -boxDimension || xSphere > boxDimension) {
      xSphere *= -1;   
      pushMatrix();
      stroke(200, 200, 0);
      strokeWeight(1);
      fill(255, 45);
      box(boxDimension*2);
      popMatrix();
    }

    if (ySphere < -boxDimension  || ySphere > boxDimension) {
      ySphere *= -1;
      pushMatrix();
      stroke(200, 200, 0);
      strokeWeight(1);
      fill(255, 45);
      box(boxDimension*2);
      popMatrix();
    }

    if (zSphere < -boxDimension  || zSphere > boxDimension) {
      zSphere *= -1;
      pushMatrix();
      stroke(200, 200, 0);
      strokeWeight(1);
      fill(255, 45);
      box(boxDimension*2);
      popMatrix();
    }

    //****************************************//     
    //************ Transition part ***********//
    //****************************************//
  } else {
    // Camera zoom in every so often but only after zoomSecond
    /*    
     float zoomFrom1 = 2.6;
     float zoomTo1 = 0.9;
     if (zoomState() == zoomTo1) { 
     float tmp = zoomFrom1; 
     zoomFrom1 = zoomTo1;
     zoomTo1 = tmp;
     zoomStart = millis();
     }
     */
    // Camera zoom in every so often but only after zoomSecond
    if (triggerFlag == 0) {
      if (s > 1000 * triggerSecond) {
        if (s % 5 >= 0 && s % 5 <= 15) {
          if (zoomState() == zoomTo) { 
            float tmp = zoomFrom; 
            zoomFrom = zoomTo;
            zoomTo = tmp;
            zoomStart = millis();
          }
        }
      }
    }

    scale(zoomState());

    // Display box particles   
    for (int i = 0; i < bp.length; i++) {
      pushMatrix();
      float intensity = fft.getBand(i);
      bp[i].display(scoreLow, scoreMid, scoreHi, intensity);
      popMatrix();

      // Display lightning strikes
      if (i > 0) {
        for (int j = 0; j < noDist; j+= 1) {
          pushMatrix();
          strokeWeight(random(1, 3));
          stroke(180, 180, 0, random(0, 255));
          dl[j].display(10, bp[i].x, bp[i].y, bp[i].z, bp[i-1].x, bp[i-1].y, bp[i-1].z);
          popMatrix();
        }
      }

      // If box particles are larger than a specific size, then redraw
      if (bp[i].drawDist() > diagonal) {
        bp[i] = new boxParticle(boxDimension);
      }
    }

    // Display sphere + update location
    for (int t=0; t < spheres.size(); t++) {
      strokeWeight(1);
      spheres.get(0).update(xSphere, ySphere, zSphere);
    }

    // Speed and direction of sphere
    xSphere += xSphereSpeed;
    ySphere += ySphereSpeed;
    zSphere += zSphereSpeed;

    // Give the sphere a chance to escape the cage
    float threshold = random(0, 100);
    for (int i = 0; i < bp.length; i++) {
      if (threshold < 7) {

        if (xSphere < -bp[i].x - bp[i].returnBoxSize() || xSphere > bp[i].x + bp[i].returnBoxSize()) {
          xSphereSpeed *= -1;
        }

        if (ySphere < -bp[i].y - bp[i].returnBoxSize() || ySphere > bp[i].y + bp[i].returnBoxSize()) {
          ySphereSpeed *= -1;
        }

        if (zSphere < -bp[i].z - bp[i].returnBoxSize() || zSphere > bp[i].z + bp[i].returnBoxSize()) {
          zSphereSpeed *= -1;
        }
      }
    }

    // If sphere exits the cage, then move spehere back to cage and show cage
    if (xSphere < -boxDimension || xSphere > boxDimension) {
      xSphere *= -1;   
      pushMatrix();
      stroke(200, 200, 0);
      strokeWeight(1);
      fill(255, 45);
      box(boxDimension*2);
      popMatrix();
    }

    if (ySphere < -boxDimension  || ySphere > boxDimension) {
      ySphere *= -1;
      pushMatrix();
      stroke(200, 200, 0);
      strokeWeight(1);
      fill(255, 45);
      box(boxDimension*2);
      popMatrix();
    }

    if (zSphere < -boxDimension  || zSphere > boxDimension) {
      zSphere *= -1;
      pushMatrix();
      stroke(200, 200, 0);
      strokeWeight(1);
      fill(255, 45);
      box(boxDimension*2);
      popMatrix();
    }
  }
}
