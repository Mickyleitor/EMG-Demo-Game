import processing.serial.*;
import processing.sound.*;


// Variables configurables
int number_stars =  1;
int number_asteroids = 60;
int number_satellites =  6;
int number_destroyed =  0;
PVector velocity_spacecraft = new PVector(5,0);
float sensibilidad = radians(0.05);
float maxturn = radians(1);
float maxvelocity = 20;
int limitRange = 5950;
int target_selected = -1;

// Objetos de renderizado
ArrayList<StarObject> Stars;
ArrayList<LaserObject> Lasers;
ArrayList<AsteroidObject> Asteroids;
ArrayList<SatelliteObject> Satellites;
PImage [] explosion = new PImage[16];
PImage cockpit,background;
PShape globe;
PFont textArialItalic,textArial;

// Sonidos
SoundFile laser,engine,turning;

// Explicacion de esto en:
// https://www.processing.org/discourse/beta/num_1139256015.html
boolean[] keys;

// Conexion con Arduino
Serial BTserial;  // Create object from Serial class
String portName;
StringList portNameBusy;
int mode = 2;
int BT_Timer = 0;
int BT_Timeout = 1000;

void setup(){
  surface.setTitle("Loading...");
  // size(displayWidth,displayHeight,P3D);
  // size(640,384,P3D);
  size(1360,768,P3D);
  hint(ENABLE_DEPTH_SORT);
  // noCursor();
  imageMode(CENTER);
  noiseSeed(0);
  
  cockpit = loadImage("cockpit.png");
  cockpit.resize(width,height);
  background = loadImage("universe.jpg");
  background.resize(int(width*9),int(width*9));
  
  globe = createShape(SPHERE, limitRange); 
  globe.setTexture(background);
 
  textArialItalic   = createFont("Arial Bold Italic", width/90);
  textArial   = createFont("Arial Bold", width/90);

  surface.setTitle("Electromyography Demostration Game");
  println("Loading ...");
  initializeArrays();
  thread("decodeKeyThread");
  portNameBusy = new StringList();
  
  laser = new SoundFile(this, "laser_sound.wav");
  engine = new SoundFile(this, "engine_sound.wav");
  turning = new SoundFile(this, "turning_sound.wav");
  engine.loop();
  turning.loop();
  turning.amp(0.5);
  // printArray(PFont.list());
}

void draw(){
  try {
    if( mode != 0 ){
      if( (mode == 2) || ((millis() - BT_Timer) < BT_Timeout) ){
        updateBackground();
        updateSounds();  
        for(int i = 0 ; i < Satellites.size() ; i++){
            Satellites.get(i).update();
            Satellites.get(i).display();
            for(int y = 0 ; y < Lasers.size() ; y++){
              Satellites.get(i).takeDamageFrom(Lasers.get(y));
            }
        }
        for(int i = 0 ; i < Asteroids.size(); i++){
            Asteroids.get(i).update();
            Asteroids.get(i).display();
        }
        for(int i = 0 ; i < Lasers.size(); i++){
            Lasers.get(i).update();
            Lasers.get(i).display();
        }
        for(int i = 0 ; i < Stars.size(); i++){
            Stars.get(i).update();
            Stars.get(i).display();
        }
        
        updateSpaceWarcraft();
        searchForRemanents();
      }else{
        BTserial.stop();
        indicarSinConexion();
      }
    }else{
      indicarSinConexion();
      buscarDispositivo();
    }
  }catch (Exception e){
    println(e);
    indicarSinConexion();
    portNameBusy.append(portName);
  }
}
void searchForRemanents(){
  ArrayList<LaserObject> NewLaserObjects = new ArrayList<LaserObject>();
  for(int i = 0 ; i < Lasers.size(); i++){
      if( abs(Lasers.get(i).position.y) < abs(limitRange)) NewLaserObjects.add(Lasers.get(i));
  }
  Lasers = NewLaserObjects;
}
void updateBackground(){
  /*
  pushMatrix();
  background(5,5,10);
  translate(width/2,height/2,-limitRange);
  shiftted_background += velocity_spacecraft.x*50;
  image(background,shiftted_background,0);
  image(background,shiftted_background+background.width,0);
  image(background,shiftted_background-background.width,0);
  if(abs(shiftted_background) > background.width)
    shiftted_background = 0;
  popMatrix();
  */
  
  pushMatrix();
  background(5,5,10);
  translate(width/2,height/2, 0);
  globe.rotateY(-velocity_spacecraft.heading());
  globe.setStroke(false);
  shapeMode(CORNER);
  shape(globe);
  popMatrix();
}
void updateSpaceWarcraft(){
  pushMatrix();
  translate(width/2,height/2,-1);
  image(cockpit,0,0);
  popMatrix();
  
  pushMatrix();
  translate(width/28,height/1.173,0);
  textAlign(LEFT);
  textFont(textArialItalic);
  fill(#ff7e07);
  rotate(-radians(6));
  text("NEUTRALIZED - "+number_destroyed+" -",0,0);
  noFill();
  popMatrix();
  
  pushMatrix();
  translate(width/2.58,height/1.255,0);
  textAlign(LEFT);
  textFont(textArial);
  fill(#ff7e07);
  text(round(((velocity_spacecraft.mag()*100)/maxvelocity))+" %",0,0);
  noFill();
  popMatrix();
  
  if(target_selected < 0){
    target_selected = int(random(1,7));
  }else{
    pushMatrix();
    translate(width/3.5,height/1.25,0);
    rotateZ((frameCount*0.01)/TWO_PI);
    imageMode(CENTER);
    tint(#ff7e07, 200);
    image(Satellites.get(target_selected-1).image,0,0,width/12,width/12);
    noTint();
    popMatrix();
  }
}

void generateBeamOfPulse(){
  laser.play();
  LaserObject NewLaser = new LaserObject();
  Lasers.add(NewLaser);
}

void initializeArrays(){
  Stars = new ArrayList<StarObject>();
  Lasers = new ArrayList<LaserObject>();
  Asteroids = new ArrayList<AsteroidObject>();
  Satellites = new ArrayList<SatelliteObject>();
  for(int i = 0 ; i < number_stars ; i++){
    StarObject Star = new StarObject(i);
    Stars.add(Star);
  }
  for(int i = 0 ; i < number_asteroids ; i++){
    AsteroidObject Asteroid = new AsteroidObject(i);
    Asteroids.add(Asteroid);
  }
  for(int i = 0 ; i < number_satellites ; i++){
    SatelliteObject Satellite = new SatelliteObject(i);
    Satellites.add(Satellite);
  }
  keys = new boolean[7];
  for(int i = 0; i < 7 ; i++) keys[i] = false;
  for(int i= 0; i < 16 ; i++){
    explosion[i] = loadImage("animations/Explosion"+(i+1)+".png");
  }
}

void updateSounds(){
  float normalized_velx = constrain(map(velocity_spacecraft.heading(),-maxturn,maxturn,-1,1),-1,1);
  turning.pan(normalized_velx);
  turning.rate((abs(normalized_velx)+0.1)*2);
  engine.rate(constrain(map(velocity_spacecraft.mag(),0,maxvelocity,0.7,5), 0, 5));
}


void buscarDispositivo(){
  for(int i = 0 ; (i < Serial.list().length) && (mode == 0); i++){
    portName = Serial.list()[i];
    if(portNameBusy.hasValue(portName) == false){
      BTserial = new Serial(this, portName, 9600);
      BTserial.clear();
      while((  (millis() - BT_Timer) < BT_Timeout) ) {
        if((millis() - BT_Timer) >= BT_Timeout){
          BTserial.stop();
        }
      }
    }
    delay(500);
  }
  if(portNameBusy.size() == Serial.list().length) portNameBusy.clear();
  if(mode > 0){
    engine.stop();
    turning.stop();
    engine.loop();
    turning.loop();
    turning.amp(0.5);
  }
}
  


void indicarSinConexion(){
  if(mode != 2) mode = 0;
  textAlign(CENTER);
  textSize(width/20);
  background(0);
  fill(255);
  text("DISPOSITIVO SIN CONEXION",width/2,height/2);
  engine.stop();
  turning.stop();
}

void serialEvent(Serial port) { 
  if(mode == 0) {
    mode = 1 ;
  }else{
    int inByte = port.read();
    switch (inByte) {
      case 'I' : {
        if(velocity_spacecraft.heading() < maxturn) velocity_spacecraft.rotate(sensibilidad);
        println("Hora: "+millis()+" Izquierda");
        break;
      }
      case 'D' : {
        if( velocity_spacecraft.heading() > -maxturn ) velocity_spacecraft.rotate(-sensibilidad);
        println("Hora: "+millis()+" Derecha");
        break;
      }
      case 'L' : {
        generateBeamOfPulse();
        println("Hora: "+millis()+" DISPARO");
        break;
      }
    }
  }
  BT_Timer = millis();
}

void decodeKeyThread() {
  while(true){
    if(keyPressed){
      /*
      if (keys[0]) {
        if( velocity_spacecraft.y < 1) velocity_spacecraft.y += sensibilidad;
      } 
      if (keys[1]) {
        if(velocity_spacecraft.y > -1) velocity_spacecraft.y -= sensibilidad;
      }
      */
      if (keys[2]) {
        if(velocity_spacecraft.heading() < maxturn) velocity_spacecraft.rotate(sensibilidad);
      } 
      if (keys[3]) {
        if( velocity_spacecraft.heading() > -maxturn ) velocity_spacecraft.rotate(-sensibilidad);
      }
      if (keys[4]) {
        if(velocity_spacecraft.mag() < maxvelocity) velocity_spacecraft.mult(1.1);
        else velocity_spacecraft.setMag(maxvelocity);
      }
      if (keys[5]) {
        if(velocity_spacecraft.mag() > 0) velocity_spacecraft.div(1.1);
        else velocity_spacecraft.setMag(0.01);
      }
      if (keys[6]) {
        keys[6] = false;
        generateBeamOfPulse();
      }
    }
    try{   
      Thread.sleep(100);
    }catch (InterruptedException e)
    {
        e.printStackTrace();
    }
  }
}

void keyPressed(){
  switch (keyCode) {
      case UP:         keys[0] = true;
                       break;
      case 87:         keys[0] = true;
                       break;
      case DOWN:       keys[1] = true;
                       break;
      case 83:         keys[1] = true;
                       break;
      case LEFT:       keys[2] = true;
                       break;
      case 65:         keys[2] = true;
                       break;
      case RIGHT:      keys[3] = true;
                       break;
      case 68:         keys[3] = true;
                       break;
      case CONTROL:    keys[4] = true;
                       break;
      case ALT:        keys[5] = true;
                       break;
      case 32:         keys[6] = true;
                       break;
  }
}

void keyReleased(){
  switch (keyCode) {
      case UP:         keys[0] = false;
                       break;
      case 87:         keys[0] = false;
                       break;
      case DOWN:       keys[1] = false;
                       break;
      case 83:         keys[1] = false;
                       break;
      case LEFT:       keys[2] = false;
                       break;
      case 65:         keys[2] = false;
                       break;
      case RIGHT:      keys[3] = false;
                       break;
      case 68:         keys[3] = false;
                       break;
      case CONTROL:    keys[4] = false;
                       break;
      case ALT:        keys[5] = false;
                       break;
  }
}
