// Uduino Default Board
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
    long value = readHX711();
    uduino.println(value);
}

long readHX711() {
    long value = 0;
    while (digitalRead(pin_dout) == HIGH);
    for (int i = 0; i < 24; i++) {
        digitalWrite(pin_slk, HIGH);
        delayMicroseconds(1);
        digitalWrite(pin_slk, LOW);
        value = value << 1;
        if (digitalRead(pin_dout) == HIGH) {
            value++;
        }
        delayMicroseconds(1);
    }
    digitalWrite(pin_slk, HIGH);
    delayMicroseconds(1);
    digitalWrite(pin_slk, LOW);
    return value;
}
