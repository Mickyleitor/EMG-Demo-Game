import processing.serial.*;
import processing.sound.*;

// Variables configurables
int number_stars =  10;
int number_asteroids =  100;
int number_satellites =  10;
PVector velocity_spacecraft = new PVector(0,0,0.1);
float sensibilidad = 0.1;

// Objetos de renderizado
int shiftted_background = 0;
ArrayList<StarObject> Stars;
ArrayList<LaserObject> Lasers;
ArrayList<AsteroidObject> Asteroids;
ArrayList<SatelliteObject> Satellites;
PImage cockpit,background;

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
  background.resize(width*8,width*8);

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
      if(Lasers.get(i).position.z > -7000) NewLaserObjects.add(Lasers.get(i));
  }
  Lasers = NewLaserObjects;
}
void updateBackground(){
  pushMatrix();
  background(5,5,10);
  translate(width/2,height/2,-5000);
  shiftted_background += velocity_spacecraft.x*50;
  image(background,shiftted_background,0);
  image(background,shiftted_background+background.width,0);
  image(background,shiftted_background-background.width,0);
  if(abs(shiftted_background) > background.width)
    shiftted_background = 0;
  popMatrix();
}
void updateSpaceWarcraft(){
  pushMatrix();
  translate(width/2,height/2,1);
  image(cockpit,0,0);
  popMatrix();
}
void mostrarAyuda(){
  pushMatrix();
  translate(width/2,height-100,0);
  image(cockpit,0,0);
  popMatrix();
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
}

void updateSounds(){
  turning.pan(constrain(velocity_spacecraft.x,-1,1));
  turning.rate(constrain((abs(velocity_spacecraft.x)+abs(velocity_spacecraft.y))+0.1,0,2));
  engine.rate(constrain(map(velocity_spacecraft.z,0,1,0.7,2), 0, 2));
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
  
void serialEvent(Serial port) { 
  if(mode == 0) {
    mode = 1 ;
  }else{
    int inByte = port.read();
    switch (inByte) {
      case 'I' : {
        if(velocity_spacecraft.x < 1) velocity_spacecraft.x += sensibilidad;
        println("Hora: "+millis()+" Izquierda");
        break;
      }
      case 'D' : {
        if(velocity_spacecraft.x > -1) velocity_spacecraft.x -= sensibilidad;
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

void indicarSinConexion(){
  if(mode != 2) mode = 0;
  textAlign(CENTER);
  textSize(width/20);
  background(0);
  text("DISPOSITIVO SIN CONEXION",width/2,height/2);
  engine.stop();
  turning.stop();
}


void decodeKeyThread() {
  while(true){
    if(keyPressed){
      if (keys[0]) {
        if( velocity_spacecraft.y < 1) velocity_spacecraft.y += sensibilidad;
      } 
      if (keys[1]) {
        if(velocity_spacecraft.y > -1) velocity_spacecraft.y -= sensibilidad;
      }
      if (keys[2]) {
        if(velocity_spacecraft.x < 1) velocity_spacecraft.x += sensibilidad;
      } 
      if (keys[3]) {
        if( velocity_spacecraft.x > -1) velocity_spacecraft.x -= sensibilidad;
      }
      if (keys[4]) {
        if(velocity_spacecraft.z < 1) velocity_spacecraft.z += sensibilidad;
        else velocity_spacecraft.z = 1;
      }
      if (keys[5]) {
        if(velocity_spacecraft.z > sensibilidad) velocity_spacecraft.z -= sensibilidad;
        else velocity_spacecraft.z = 0;
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
