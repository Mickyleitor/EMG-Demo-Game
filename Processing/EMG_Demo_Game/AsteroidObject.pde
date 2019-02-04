class AsteroidObject {
  PVector position;
  PShape model;
  PVector velocity;
  PImage image;
  int max_size_image = width/30;
  int actual_size_image;
  int myId;
  
  void display(){
    if(isInLOS()){
      pushMatrix();
      translate(position.x  +width/2,position.z +height/2,position.y + width/2);
      actual_size_image = constrain(int(map(position.mag(),width*0.5,width*2,max_size_image,1)),1,max_size_image);
      rotateZ((velocity.heading()*frameCount)*(HALF_PI/300));
      image(image,0,0,actual_size_image,actual_size_image);
      textAlign(CENTER);
      textSize(50);
      // text(position.z,0,100);
      popMatrix();
    }
  }
  void update(){
    if( isInLOS() ) {
      position.rotate(velocity_spacecraft.heading());
      position.add(0,velocity_spacecraft.x, 0);
      position.add(velocity);

    }else{
      createNewPosition();
    }
  }
  void createNewPosition(){
    position = PVector.random3D();
    position.setMag(random(width*2,width*2.5));
    velocity = PVector.random3D();
    velocity.setMag(random(0,0.3));
  }
  boolean isInLOS(){
    return (( position.mag() < abs(limitRange) ) &&  (position.y + width/2) < -1 ) ;
  }
  
  AsteroidObject(int id){
    myId = id;
    image = loadImage("Asteroid"+(id%2 + 1)+".png");
    max_size_image += random(0,max_size_image);
    createNewPosition();
  }
}
