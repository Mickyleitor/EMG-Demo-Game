class LaserObject {
  PVector position;
  PVector velocity;
  PImage image;
  int max_size_image = width/7;
  boolean isMuzzle = true;
  
  void display(){
    pushMatrix();
    translate(position.x  +width/2,position.z + height/2,position.y + width/2);
    image(image,0,0,max_size_image,max_size_image);
    popMatrix();
    if(isMuzzle){
      isMuzzle = false;
      background(255,0,0,0.1);
    }
  }
  void update(){
      position.rotate(velocity_spacecraft.heading());
      position.add(0,velocity_spacecraft.x, 0);
      position.add(velocity);
  }
  
  LaserObject(){
    position = new PVector(0,-height/2,0);
    velocity = new PVector(0,-100,0);
    image = loadImage("Laser.png");
  }
}
