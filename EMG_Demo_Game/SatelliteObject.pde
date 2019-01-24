class SatelliteObject {
  PVector position = new PVector(10,10,10);
  PVector velocity = new PVector(random(-2,2),0,1000);
  PVector velocity_spacecraft = new PVector(0,0,0);
  PImage [] image = new PImage[6];
  PImage [] explosion = new PImage[16];
  boolean isInRange   = true;
  boolean isDestroyed = false;
  int size_image = 30;
  int count_animation = 0;
  int selected_satellite = int(random(1,6));
  
  
  void display(){
    pushMatrix();
    translate(position.x,position.y,position.z);
    rotate(velocity.heading());
    if(isDestroyed){
      image(explosion[count_animation],0,0); 
    }else{
      image(image[selected_satellite],0,0); 
    }
    popMatrix();
  }
  
  void update(){
    if( isInLOS() ) {
      
      position.y += map(abs(position.z),0,7000,0,velocity_spacecraft.y*height/10);
      position.x += map(abs(position.z),0,7000,0,velocity_spacecraft.x*width/10);
      PVector new_velocity = velocity.copy();
      new_velocity.z = new_velocity.z * (  pow(2,(velocity_spacecraft.z)) - 1);
      
      if((position.z + new_velocity.z) < -1) position.add(new_velocity);
      else isInRange = false;
      
      if(isDestroyed){
        if( frameCount%4 == 0){
          if(count_animation >= 15) isInRange = false;
          else{
            count_animation ++;
          }
        }
      }
      
    }else{
      noiseSeed(0);
      // PVector NewPosition = new PVector(random(-width*4,width*5),height/2,random(-10000,-5000));
      position = new PVector(random(-width*4,width*5),random(height/2+height/100,height/2-height/100),random(-10000,-5000));
      isInRange = true;
      if(isDestroyed){
        count_animation = 0;
        int selected_satellite = int(random(1,6));
        isDestroyed = false;
      }
    }
  }
  boolean isInLOS(){
    return ((position.z < -1) && isInRange);
  }
  void takeDamageFrom(LaserObject laser){
    PVector distance = position.copy();
    distance.sub(laser.position);
    if(distance.mag() < size_image*2){ 
      isDestroyed = true;
      println("Object in "+position+" impacted by laser at "+laser.position);
    }
  }
  
  SatelliteObject(){
    for(int i= 0; i < 6 ; i++){
      image[i] = loadImage("bin"+(i+1)+".png");
      image[i].resize(size_image,size_image);
    }
    for(int i= 0; i < 16 ; i++){
      explosion[i] = loadImage("animations/Explosion"+(i+1)+".png");
      explosion[i].resize(size_image,size_image);
    }
  }
}
