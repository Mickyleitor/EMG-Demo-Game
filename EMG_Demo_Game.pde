import processing.serial.*;

Serial BTListener;  // Create object from Serial class
Serial BTWritter;
// mode 0 : No COM detected
//         (BT module opens 2 ports, one for writting and other for reading)
// mode 1 : Searching for COM Writter (BT module opens 2 ports, one for writting and other for reading)
// mode 2 : Searching for COM Listener
// mode 3 : Device connected
int mode = 0;
String portNameWritter;
String portNameListener;

void setup() 
{
  size(1280, 768);
}

void draw()
{
  switch(mode){
    case 1 : {
      searchBTWritter();
      break;
    }
    case 2 : {
      searchBTListener();
      break; 
    }
    case 3 : {
      background(128);
      textAlign(CENTER);
      textSize(width/40);
      text("DISPOSITIVO DETECTADO",width/2,height/1.5);
      break;
    }
    default : {
      background(128);
      textAlign(CENTER);
      textSize(width/40);
      text("NO SE HA DETECTADO EL DISPOSITIVO\nCOMPRUEBE LA CONEXIÓN BLUETOOTH",width/2,height/1.5);
      mode = 1;
      break;
    }
  }
}


void searchBTWritter(){
  printArray(Serial.list());
  if(Serial.list().length == 0){
    mode = 0;
  }else{ //<>//
    for(int i = 0; i < Serial.list().length; i = i+1){
      portNameWritter = Serial.list()[i];
      BTWritter = new Serial(this, portNameWritter, 9600);
      byte received = 0;
      int time = millis();
      while( (received != 5) && ((millis() - time) < 2000)){
        if ( BTWritter.available() > 0) {  // If data is available,
          received = BTWritter.readBytes(1)[0];     // read it and store it in val
          // Si se recibe un caracter ENQ (Enquiry)
          // Guardar como COM de lectura
          if(received == 5){
            mode = 2;
          }else{
            mode = 0;
          }
        }
      }
      if(mode == 0){
        BTWritter.stop();
      }
    }
  }
}

void searchBTListener(){
  printArray(Serial.list());
  if(Serial.list().length == 0){
    mode = 0;
  }else{
    for(int i = 0; i < Serial.list().length; i = i+1){
      portNameListener = Serial.list()[i];
      if(portNameListener != portNameWritter){
        BTListener = new Serial(this, portNameListener, 9600);
        byte received = 0;
        int time = millis();
        while( (received != 6) && ((millis() - time) < 2000)){
          // Enviar caracter de sincronización (SYN)
          BTListener.write(22);
          if ( BTWritter.available() > 0) {  // If data is available,
            received = BTWritter.readBytes(1)[0];     // read it and store it in val
            // Si se recibe caracter de acuse de recibo (ACK)
            // Guardar como COM de escritura
            if(received == 6){
              mode = 3;
            }else{
              mode = 2;
            }
          }
        }
        if(mode == 2){
          BTListener.stop();
        }
      }
    }
    // Si en este paso no se ha podido encontrar el dispositivo
    // de escritura, cerrar todos los puertos y reanudar busqueda
    if(mode != 3){
      BTWritter.stop();
      mode = 0;
    }
  }
}
