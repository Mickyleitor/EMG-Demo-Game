class StarObject {
  PVector position;
  PVector velocity;
  PImage image;
  boolean isInRange = true;
  int max_size_image = width/2;
  int actual_size_image = 1;
  int myId;
  
  void display(){
    if(isInLOS()){
      pushMatrix();
      translate(position.x+width/2,position.z+height/2,position.y + width/2);
      actual_size_image = int(map(position.mag(),limitRange*0.8,limitRange*0.9,max_size_image,1));
      image(image,0,0,actual_size_image,actual_size_image);
      textAlign(CENTER);
      textSize(100);
      // text(position.mag(),0,200);
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
    position = new PVector(random(-limitRange,limitRange),random(-limitRange,limitRange),random(-limitRange/4,limitRange/4));
    position.setMag(random(limitRange*0.88,limitRange*0.9));
    velocity = PVector.random3D();
    velocity.setMag(random(0,1));
  }
  boolean isInLOS(){
    return (( position.mag() < abs(limitRange) ) &&  (position.y + width/2) < -1 ) ;
  }
  
  StarObject(int id){
    myId = id;
    image = loadImage("star"+(id%2 + 1)+".png");
    max_size_image += random(0,max_size_image);
    // image.resize(max_size_image,max_size_image);
    createNewPosition();
  }
}
