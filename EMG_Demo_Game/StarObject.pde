class StarObject {
  PVector position = new PVector(10,10,10);
  PVector velocity = new PVector(0,0,100);
  PVector velocity_spacecraft = new PVector(0,0,0);
  PImage image;
  boolean isInRange = true;
  int size_image = 1000;
  
  void display(){
    pushMatrix();
    translate(position.x,position.y,position.z);
    image(image,0,0);
    if(position.z >= -1) println("IsOutOfRange");
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

    }else{
      noiseSeed(0);
      position = new PVector(random(-width*4,width*5),random(-height*4,height*5),random(-7000,-50));
      isInRange = true;
    }
  }
  boolean isInLOS(){
    return ((position.z < -1) && isInRange);
  }
  
  StarObject(){ 
    image = loadImage("star.png");
    size_image = size_image * int(random(1,2.5));
    image.resize(size_image,size_image);
  }
}
