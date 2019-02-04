class SatelliteObject {
  PVector position;
  PVector velocity;
  PImage image;
  boolean isDestroyed = false;
  int max_size_image = width/7;
  int actual_size_image;
  int count_animation = 0; 
  int myId;
  
  void display(){
    pushMatrix();
    translate(position.x  +width/2,position.z +height/2,position.y + width/2);
    actual_size_image = constrain(int(map(position.mag(),limitRange*0.6,limitRange*0.88,max_size_image,1)),1,max_size_image);
    rotateZ((myId*frameCount)*(HALF_PI/5000));
    if(isDestroyed){
      image(explosion[count_animation],0,0,actual_size_image,actual_size_image); 
    }else{
      image(image,0,0,actual_size_image,actual_size_image); 
    }
    popMatrix();
  }
  
  void update(){
    if( isInLOS() ) {
      position.rotate(velocity_spacecraft.heading());
      position.add(0,velocity_spacecraft.x, 0);
      position.add(velocity);
      // velocity.rotate(-velocity_spacecraft.heading());
      
      if(isDestroyed){
        if( frameCount%4 == 0){
          if(count_animation >= 15){
            createNewPosition();
          }else{
            count_animation ++;
          }
        }
      }

    }else{
      createNewPosition();
    }
  }
  boolean isInLOS(){
    return (( position.mag() < abs(limitRange) ) &&  (position.y + width/2) < -1 ) ;
  }
  
  void takeDamageFrom(LaserObject laser){
    PVector distance = position.copy();
    distance.sub(laser.position);
    if((distance.mag() < actual_size_image*0.5) && !isDestroyed){
      isDestroyed = true;
      if(target_selected == (myId%6 + 1)){
        number_destroyed += 1;
        target_selected = -1;
      }
      println("Object in "+position+" impacted by laser at "+laser.position);
    }
  }
  
  void createNewPosition(){
    position = new PVector(random(-limitRange,limitRange),random(-limitRange,limitRange),0);
    position.setMag(random(limitRange*0.88,limitRange*0.9));
    velocity = new PVector(random(-1,1),0,0);
    isDestroyed = false;
    count_animation = 0;
  }
  
  SatelliteObject(int id){
    myId = id;
    image = loadImage("bin"+(id%6 + 1)+".png");
    createNewPosition();
  }
}
