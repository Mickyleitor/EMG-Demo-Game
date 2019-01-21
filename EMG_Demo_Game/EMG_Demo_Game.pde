ArrayList<StarObject> Stars;
ArrayList<LaserObject> Lasers;
ArrayList<AsteroidObject> Asteroids;
ArrayList<SatelliteObject> Satellites;
PImage cockpit;
int number_stars =  20;
int number_asteroids =  int(number_stars*10);
int number_satellites =  int(number_stars/2);
PVector velocity_spacecraft = new PVector(0,0,0.1);
float sensibilidad = 0.01;

// Explicacion de esto en:
// https://www.processing.org/discourse/beta/num_1139256015.html
boolean[] keys;

// Conexion con Arduino
import processing.serial.*;
Serial BTserial;  // Create object from Serial class
String portName;
StringList portNameBusy;
int mode = 0;
int BT_Timer = 0;
int BT_Timeout = 1000;

void setup(){
  // size(1360,768,P3D);
  size(1360,768,P3D);
  // size(640,384,P3D);
  imageMode(CENTER);
  noiseSeed(0);
  hint(ENABLE_DEPTH_SORT);
  indicarSinConexion();
  cockpit = loadImage("cockpit.png");
  cockpit.resize(width,height);
  println("Loading ...");
  initializeArrays();
  thread("decodeKeyThread");
  portNameBusy = new StringList();
}

void draw(){
  try {
    if( mode == 1 ){
      if((millis() - BT_Timer) < BT_Timeout){
        background(5,5,20);
        
        for(int i = 0 ; i < Satellites.size() ; i++){
            Satellites.get(i).velocity_spacecraft = velocity_spacecraft;
            Satellites.get(i).update();
            Satellites.get(i).display();
            for(int y = 0 ; y < Lasers.size() ; y++){
              Satellites.get(i).takeDamageFrom(Lasers.get(y));
            }
        }
        for(int i = 0 ; i < Asteroids.size(); i++){
            Asteroids.get(i).velocity_spacecraft = velocity_spacecraft;
            Asteroids.get(i).update();
            Asteroids.get(i).display();
        }
        for(int i = 0 ; i < Lasers.size(); i++){
            Lasers.get(i).velocity_spacecraft = velocity_spacecraft;
            Lasers.get(i).update();
            Lasers.get(i).display();
        }
        for(int i = 0 ; i < Stars.size(); i++){
            Stars.get(i).velocity_spacecraft = velocity_spacecraft;
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

void updateSpaceWarcraft(){
  pushMatrix();
  translate(width/2,height/2,0);
  image(cockpit,0,0);
  popMatrix();
}
void generateBeamOfPulse(){
    LaserObject NewLaser = new LaserObject();
    Lasers.add(NewLaser);
}

void initializeArrays(){
  Stars = new ArrayList<StarObject>();
  Lasers = new ArrayList<LaserObject>();
  Asteroids = new ArrayList<AsteroidObject>();
  Satellites = new ArrayList<SatelliteObject>();
  for(int i = 0 ; i < number_stars ; i++){
    StarObject Star = new StarObject();
    Stars.add(Star);
  }
  for(int i = 0 ; i < number_asteroids ; i++){
    AsteroidObject Asteroid = new AsteroidObject();
    Asteroids.add(Asteroid);
  }
  for(int i = 0 ; i < number_satellites ; i++){
    SatelliteObject Satellite = new SatelliteObject();
    Satellites.add(Satellite);
  }
  keys = new boolean[7];
  for(int i = 0; i < 7 ; i++) keys[i] = false;
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
        if(velocity_spacecraft.z > 0) velocity_spacecraft.z -= sensibilidad;
        else velocity_spacecraft.z = 0;
      }
      if (keys[6]) {
        keys[6] = false;
        generateBeamOfPulse();
      }
    }
    try{   
      Thread.sleep(10);
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
}
  
void serialEvent(Serial port) { 
  if(mode == 0) {
    mode = 1 ;
  }else{
    int inByte = port.read();
    switch (inByte) {
      case 'L' : {
        generateBeamOfPulse();
        break;
      }
      case 'I' : {
        if(velocity_spacecraft.x < 1) velocity_spacecraft.x += sensibilidad;
        break;
      }
      case 'D' : {
        if(velocity_spacecraft.x > -1) velocity_spacecraft.x -= sensibilidad;
        break;
      }
    }
  }
  BT_Timer = millis();
}

void indicarSinConexion(){
  mode = 0;
  textAlign(CENTER);
  textSize(width/20);
  background(0);
  text("DISPOSITIVO SIN CONEXION",width/2,height/2);  
}
