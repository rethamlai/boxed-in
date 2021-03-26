// https://github.com/samuellapointe/ProcessingCubes
// https://www.openprocessing.org/sketch/492680
class boxParticle {
  float n;
  float r;
  float o;
  int l;
  
  float x,y,z;
  
  
  boxParticle(float boxDimension) {
    
    l = 1;
    n = random(1, width/2);
    r = random(0, TWO_PI);
    o = random(1, random(1, width/n));
     
    z = (random(-1,1))*boxDimension;
    x = (random(-1,1))*boxDimension;
    y = (random(-1,1))*boxDimension;
  }

  void display(float scoreLow, float scoreMid, float scoreHi, float intensity) {
    l++;
    pushMatrix();
    translate(x,y,z);
    fill(abs(25 - min(random(0,100),scoreLow)*intensity),
         abs(25 - min(random(0,100),scoreMid)*intensity),
         abs(25 - min(random(0,100),scoreHi)*intensity));
    strokeWeight(1);
    stroke(255);
    box(width/o/10);
    popMatrix();
    
    if (key == 'r') {
     x = x + random(-1,1)/3;
     y = y + random(-1,1)/3;
     z = z + random(-1,1)/3;
    }
  }
  float drawDist() {
    return atan(n/o)*width/HALF_PI;
  }
  float returnX() {
   return x; 
  }
  float returnY() {
   return y; 
  }
  float returnZ() {
   return z; 
  }
  float returnBoxSize() {
   return width/o/10;
  }
}


// https://www.openprocessing.org/sketch/199700/
class DistortedLine {
 
 DistortedLine() {  
 }

 void display(float r, float xObjectStart, float yObjectStart, float zObjectStart,
 float xObjectEnd, float yObjectEnd, float zObjectEnd) {
   
  float xDistortedLine, yDistortedLine, zDistortedLine;
  float randomStrikeTime = random(0,1000);
  float randomStrikeTimeThreshold = r;
  
  if (randomStrikeTime < randomStrikeTimeThreshold) {
    
    xDistortedLine = xObjectStart;
    yDistortedLine = yObjectStart;
    zDistortedLine = zObjectStart;
    
    while (yDistortedLine < yObjectEnd && xDistortedLine < xObjectEnd && zDistortedLine < zObjectEnd) {
       
       float endXDistortedLine = xDistortedLine + parseInt(random(-10,10)); 
       float endYDistortedLine = yDistortedLine + 1; 
       float endzDistortedLine = zDistortedLine + parseInt(random(-10,10));
       
       line(xDistortedLine,yDistortedLine,zDistortedLine,endXDistortedLine,endYDistortedLine,endzDistortedLine);
       
       xDistortedLine = endXDistortedLine;
       yDistortedLine = endYDistortedLine;
       zDistortedLine = endzDistortedLine;
    } 
  }
 } 
}
  
  
// https://discourse.processing.org/t/defining-coordinates-of-a-sphere/9813/4  
class SphereLoc {
  float x, y, z, r;
  SphereLoc(float x, float y, float z, float r){
    this.x = x;
    this.y = y;
    this.z = z;
    this.r = r;
  }
  void update(float x, float y, float z) {
    translate(x, y, z);
    sphere(r);
    translate(-x, -y, -z);
  }
}



//Wall class
class Wall {

  float startingZ = -10000;
  float maxZ = 50;
  float x, y, z;
  float sizeX, sizeY;

  Wall(float x, float y, float sizeX, float sizeY) {
    this.x = x;
    this.y = y;
    this.z = random(startingZ, maxZ);  
    this.sizeX = sizeX;
    this.sizeY = sizeY;
  }

  void display(float scoreLow, float scoreMid, float scoreHi, float intensity, float scoreGlobal) {
    color displayColor = color(scoreLow*0.55, scoreMid*0.9, random(200, 255), scoreGlobal);

    fill(displayColor, ((scoreGlobal-5)/1000)*(255+(z/25)));
    noStroke();

    pushMatrix();

    translate(x, y, z);

    if (intensity > 100) intensity = 100;
    scale(sizeX*(intensity/100), sizeY*(intensity/100), 20);

    box(1);
    popMatrix();

    displayColor = color(scoreLow*0.5, scoreMid*0.5, scoreHi*0.5, scoreGlobal);
    fill(displayColor, (scoreGlobal/5000)*(255+(z/25)));
    
    pushMatrix();

    translate(x, y, z);

    scale(sizeX, sizeY, 10);

    box(1);
    popMatrix();

    z+= (pow((scoreGlobal/150), 2));
    if (z >= maxZ) {
      z = startingZ;
    }
  }
}
