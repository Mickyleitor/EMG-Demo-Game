class LaserObject {
  PVector position;
  PVector velocity;  
  PImage image;
  boolean isMuzzle = true;
  int size_image = width/7;
  
  
  void display(){
    pushMatrix();
    translate(position.x,position.y,position.z);
    image(image,0,0);
    popMatrix();
    if(isMuzzle){
      isMuzzle = false;
      background(255,0,0,0.1);
    }
  }
  
  void update(){
    position.y += map(abs(position.z),0,7000,0,velocity_spacecraft.y*height/10);
    position.x += map(abs(position.z),0,7000,0,velocity_spacecraft.x*width/10);
    position.add(velocity);
  }
  
  LaserObject(){ 
    position = new PVector(width/2,height/1.9,-1);
    velocity = new PVector(0,0,-100);
    image = loadImage("Laser.png");
    image.resize(size_image,size_image);
    
  }
}
