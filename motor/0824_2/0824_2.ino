#include<Uduino.h>
Uduino uduino("uduinoBoard");

#define pin_dout  8
#define pin_slk   9

void setup() {
    Serial.begin(9600);
    pinMode(pin_slk, OUTPUT);
    pinMode(pin_dout, INPUT);
    digitalWrite(pin_slk, LOW);
    
    uduino.addCommand("getWeight", sendHX711Value);
}

void loop() {
    uduino.update();
}

void sendHX711Value() {
    long value = AE_HX711_Read();
    //uduino.println(value - offset); // オフセット値を引く
    uduino.println(value );
    //Serial.println(value);
}

long AE_HX711_Read(void)
{
  long data=0;
  while(digitalRead(pin_dout)!=0);
  delayMicroseconds(10);
  for(int i=0;i<24;i++)
  {
    digitalWrite(pin_slk,1);
    delayMicroseconds(5);
    digitalWrite(pin_slk,0);
    delayMicroseconds(5);
    data = (data<<1)|(digitalRead(pin_dout));
  }
  //Serial.println(data,HEX);   
  digitalWrite(pin_slk,1);
  delayMicroseconds(10);
  digitalWrite(pin_slk,0);
  delayMicroseconds(10);
  return data^0x800000; 
}

