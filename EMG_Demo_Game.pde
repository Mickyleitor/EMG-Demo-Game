import processing.serial.*;

Serial BT_Input;
String portNameBT_Input;
int mode = 0;

void setup() 
{
  size(1280, 768);
  printArray(Serial.list());
  if(Serial.list().length > 0){
    portNameBT_Input = Serial.list()[0];
    BT_Input = new Serial(this, portNameBT_Input, 9600);
    mode = 1;
  }
}

void draw()
{
  if( mode == 1){
    if( BT_Input.available() > 0){
      int value = BT_Input.read();
      // background(128);
      textAlign(CENTER);
      textSize(width/20);
      if(value == 'A'){
        background(255,0,0);
        text("DERECHA",width/1.5,height/2);
      }else if(value == 'B'){
        background(255,255,0);
        text("IZQUIERDA",width/3,height/2);
      }
    }
  }else{
    textAlign(CENTER);
    textSize(width/20);
    background(0);
    text("DISPOSITIVO SIN CONEXION",width/2,height/2);
  }
} //<>//
