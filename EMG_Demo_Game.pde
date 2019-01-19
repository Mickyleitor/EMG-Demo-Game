/*
	EMG Demonstration Game Proccessing code
	Author : Micky
*/


import processing.serial.*;

Serial BTserial;
String portName;
StringList portNameBusy;
int mode = 0;
int BT_Timer = 0;
int BT_Timeout = 1000;

void setup() 
{
    size(1280, 768);
    portNameBusy = new StringList();
    indicarSinConexion();
}

void draw()
{
  try {
    if( mode == 1 ){
      if( BTserial.available() > 0 ){
          int value = BTserial.read();
          textAlign(CENTER);
          textSize(width/20);
          if(value == 'D'){
            background(255,0,0);
            text("DERECHA",width/1.5,height/2);
          }else if(value == 'I'){
            background(255,255,0);
            text("IZQUIERDA",width/3,height/2);
          }
        }else if((millis() - BT_Timer) > BT_Timeout){
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
  if(port == BTserial){
    mode = 1 ;
    BT_Timer = millis();
  }
} 

void indicarSinConexion(){
  mode = 0;
  textAlign(CENTER);
  textSize(width/20);
  background(0);
  text("DISPOSITIVO SIN CONEXION",width/2,height/2);  
}

/*
// ARDUINO LEONARDO CODE
#define WATCHDOG_PIN 2
#define LED 13

void setup(){
  pinMode(LED,OUTPUT);
  pinMode(WATCHDOG_PIN,OUTPUT);
  Serial1.begin(9600);
  while(!Serial1){}
  tone(WATCHDOG_PIN,1);
  attachInterrupt(digitalPinToInterrupt(WATCHDOG_PIN),watchdog,FALLING);
  randomSeed(analogRead(0));
}
void loop(){
  if(random()%2 == 0){
    Serial1.write('I');
    digitalWrite(LED, HIGH);
  }else{
    Serial1.write('D');
    digitalWrite(LED, LOW);
  }
  delay(500);
}

void watchdog(){
  Serial1.write('W');
}
*/
