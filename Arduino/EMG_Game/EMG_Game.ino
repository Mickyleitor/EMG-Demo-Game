
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
const unsigned int UMBRAL_MUESTRAS = 90;
const unsigned int UMBRAL_SENAL = 14;
const unsigned UMBRAL_DERIVA = 50;
const unsigned long PERIODO_SH = 200;
volatile unsigned char CurrentCh;         //Canal del cual está leyendo el ADC
volatile unsigned int ADC_Value = 0;    //Valor leído por el ADC
unsigned long buff_1[NUMCHANNELS];
unsigned long buff_envio[NUMCHANNELS];
volatile unsigned int INDICE = 0;
unsigned long UMBRAL_MUESTREO = 0;

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

    if((buff_envio[0] == 1)&&(buff_envio[1]==1)){
      Serial1.write('L');
      Serial.print("SEÑAL ENVIADA en el canal: "); //ain 1 shield arriba
      Serial.println("Disparo");
    }else{
      if((buff_envio[0] == 1)){
        Serial1.write('D');
        Serial.print("SEÑAL ENVIADA en el canal: ");
        Serial.println(0);
      }
      if((buff_envio[1] == 1)){
        Serial1.write('I');
        Serial.print("SEÑAL ENVIADA en el canal: ");
        Serial.println(1);
      }
    }
    INDICE = 0;
  }
  
  interrupts();
} 

//-----------------Inicio del programa---------------

struct Shield sh;

void setup() {

   noInterrupts();
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
   
   interrupts();

}

void loop() {
  unsigned long curr = millis();
  loop_sh(sh,curr);
}

//***** Rutina interrupcion Timer2 *****************
void Timer2_Overflow_ISR()
{
  //Leemos cada canal de entrada
  for(CurrentCh=0;CurrentCh<NUMCHANNELS;CurrentCh++){
    ADC_Value = analogRead(CurrentCh);
    if(ADC_Value>UMBRAL_MUESTREO){
       buff_1[CurrentCh]++;
    }
  }
  INDICE++;
}
void watchdog(){
  Serial1.write('d');
}
