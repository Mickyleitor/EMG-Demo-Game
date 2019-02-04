
#include <compat/deprecated.h>
#include <FlexiTimer2.h>

// All definitions
#define NUMCHANNELS 2
#define SAMPFREQ 256                      // ADC sampling rate 256
#define TIMER2VAL (1024/(SAMPFREQ))       // Set 256Hz sampling frequency                    
#define LED1 7
#define LED2 6
#define CAL_SIG 9
#define WATCHDOG_PIN 2

// Global constants and variables
const unsigned int UMBRAL_MUESTRAS = 180;
const unsigned int UMBRAL_SENAL = 12;
const unsigned UMBRAL_DERIVA = 50;
const unsigned long PERIODO_SH = 200;
volatile unsigned char CurrentCh;         //Current channel being sampled.
volatile unsigned int ADC_Value = 0;    //ADC current value
//volatile unsigned int buff[NUMCHANNELS][UMBRAL_MUESTRAS];
unsigned long buff_1[NUMCHANNELS];
unsigned long buff_envio[NUMCHANNELS];
volatile unsigned int INDICE = 0;
unsigned long UMBRAL_MUESTREO = 0;
//

void Toggle_LED1(void){

 if((digitalRead(LED1))==HIGH){ digitalWrite(LED1,LOW); }
 else{ digitalWrite(LED1,HIGH); }
 
}

void Toggle_LED2(void){

 if((digitalRead(LED2))==HIGH){ digitalWrite(LED2,LOW); }
 else{ digitalWrite(LED2,HIGH); }
 
}

//-------------------Estructuras-----------------
struct Shield {
    unsigned long period_ms;
    unsigned long last_ms;
    float umbral;
    float v_neutro;
};

//-------------------Setups---------------------

void setup_sh(struct Shield& sh, unsigned long p)
{
    sh.period_ms = p;
    sh.last_ms = 0;
    sh.v_neutro = 330;
    sh.umbral = sh.v_neutro + UMBRAL_DERIVA;
    UMBRAL_MUESTREO=sh.umbral;
}

//-------------------Loops----------------------------

void loop_sh(struct Shield& sh,unsigned long curr_ms)
{ 
  noInterrupts();
  if(INDICE >= UMBRAL_MUESTRAS){
    for(int i=0;i<NUMCHANNELS;i++){
      if(buff_1[i]>UMBRAL_SENAL){
         Serial.print("SEÑAL DETECTADA en el canal: ");
         Serial.println(i);
         buff_envio[i]=1;       
         buff_1[i]=0;
      }else{
         buff_1[i]=0;
         buff_envio[i]=0;
      }
    }

    if((buff_envio[0] == 1)){
      Serial1.write('D');
      Serial.print("SEÑAL ENVIADA en el canal: "); //ain 1 shield arriba
      Serial.println(0);
      }
    if((buff_envio[1] == 1)){
      Toggle_LED1();
      Serial1.write('I');
      Serial.print("SEÑAL ENVIADA en el canal: ");
      Serial.println(1);
      }
    INDICE = 0;
  }
  
  interrupts();
} 

//-----------------Inicio del programa---------------

struct Shield sh;

void setup() {

   noInterrupts();  // Disable all interrupts before initialization
   // LED1
   pinMode(LED1, OUTPUT);  //Setup LED1 direction
   pinMode(6, OUTPUT);
   digitalWrite(LED1,HIGH); //Setup LED1 state
   digitalWrite(LED2,HIGH);
   FlexiTimer2::set(TIMER2VAL, Timer2_Overflow_ISR);
   FlexiTimer2::start();
   for(int i=0;i<NUMCHANNELS;i++){
      buff_1[i]=0;
   }
   Serial1.begin(9600);// abrimos bluetooth
   while(!Serial1){}

   Serial.begin(57600);
   setup_sh(sh,PERIODO_SH);

   pinMode(WATCHDOG_PIN,OUTPUT);
   tone(WATCHDOG_PIN,1);
   attachInterrupt(digitalPinToInterrupt(WATCHDOG_PIN),watchdog,FALLING);
   
   interrupts();  // Enable all interrupts after initialization has been completed
 


  
}

void loop() {
  unsigned long curr = millis();
  loop_sh(sh,curr);
}

//***** Rutina interrupcion Timer2 *****************
void Timer2_Overflow_ISR()
{
  // Toggle LED1 with ADC sampling frequency /2
  //Toggle_LED1();
  
  //Read the 6 ADC inputs and store current values in Packet
  for(CurrentCh=0;CurrentCh<NUMCHANNELS;CurrentCh++){
    ADC_Value = analogRead(CurrentCh);
    if(ADC_Value>UMBRAL_MUESTREO){
       buff_1[CurrentCh]++;
    }
    //buff[CurrentCh][INDICE]=ADC_Value;
  }
  INDICE++;
  /*
  if(INDICE==UMBRAL_MUESTRAS){
    INDICE=0;
  }*/
}
void watchdog(){
  Serial1.write('d');
}
