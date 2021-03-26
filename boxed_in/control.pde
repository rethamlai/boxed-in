void keyPressed()
{
  if ( key == 'f' )
  {
    song.skip(2000);
  } 
}

// https://forum.processing.org/two/discussion/18345/smooth-zoom-on-mouse-click-easing-and-stop-zooming
// Zoom in
float zoomState(){
  float elapsed = millis() - zoomStart;
  if(elapsed < zoomDuration){
    return lerp(zoomFrom, zoomTo, elapsed/zoomDuration);
  }
  else{
    return zoomTo;
  }
}
