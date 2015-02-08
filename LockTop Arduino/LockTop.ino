#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <services.h>

const int redLedPin = 2;
const int ledPin2 = 3;
const int speakerOut = 4; /* This makes a standard old PC speaker connector fit nicely over the pins. */
const int buttonA = 6;
const int buttonB = 7;

byte readVal = 0x00;
double x2, y2, z2;
bool firstTime = true;
char code[4] = {'a','b','a','b'};
char last4 ='c', last3 ='c', last2 = 'c', last1 = 'c';

void printAccels(double x, double y, double z){
  
  Serial.print("accels are x, y, z: ");
  Serial.print(x, DEC);    // print the acceleration in the X axis
  Serial.print(" ");       // prints a space between the numbers
  Serial.print(y, DEC);    // print the acceleration in the Y axis
  Serial.print(" ");       // prints a space between the numbers
  Serial.println(z, DEC);  // print the acceleration in the Z axis
}

void setup() {
  
  ble_begin();
  
  pinMode(buttonA,INPUT);
  pinMode(buttonB,INPUT);
  pinMode(redLedPin, OUTPUT); 
  pinMode(ledPin2, OUTPUT); 
  pinMode(speakerOut, OUTPUT);
  digitalWrite(redLedPin,LOW);
  digitalWrite(ledPin2,LOW);

  Serial.begin(57600);
}

void loop() {
  // put your main code here, to run repeatedly: 
  if(ble_connected()){
    digitalWrite(ledPin2,HIGH);
  }
  
  if(ble_available()){
    readVal = ble_read();
  }
  
  if(readVal == 0x01){
      digitalWrite(redLedPin,HIGH);
      if(firstTime){
        z2 = analogRead(3);       // read analog input pin 0
        y2 = analogRead(4);       // read analog input pin 1
        x2 = analogRead(5);       // read analog input pin 2
        firstTime = false;
        Serial.print("firstTime ");
        printAccels(x2, y2, z2);
      }
      double z1 = analogRead(3);       // read analog input pin 0
      double y1 = analogRead(4);       // read analog input pin 1
      double x1 = analogRead(5);       // read analog input pin 2
      printAccels(x1, y1, z1);

      if((abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)) > 50) {
        ble_write(0x00);
        ble_do_events();
        printAccels(abs(x1 - x2), abs(y1 - y2), abs(z1 - z2));
        
        while(true){
          //unless hard reset ^^
          digitalWrite(ledPin2, HIGH);
          digitalWrite(redLedPin, LOW);
	  noTone(speakerOut);
	  tone(speakerOut, 440, 200);
	  noTone(speakerOut);
	  tone(speakerOut, 494, 500);
	  noTone(speakerOut);
	  tone(speakerOut, 523, 300);
          delay(100);
          digitalWrite(ledPin2, LOW);
          digitalWrite(redLedPin, HIGH);
          delay(100);
          if(digitalRead(buttonA) == LOW){
            last1 = last2;
            last2 = last3;
            last3 = last4;
            last4 = 'a';
          }
          if(digitalRead(buttonB) == LOW){
            last1 = last2;
            last2 = last3;
            last3 = last4;
            last4 = 'b';
          }
          if(last1 = code[0] && last2 == code[1] && last3 == code[2] && last4 == code[3]){
            ble_write(0x01);
            noTone(speakerOut);
            break;
          }
        }
      } else {
        ble_write(0x01);
        noTone(speakerOut);
      }
  } else {
      digitalWrite(redLedPin,LOW);
      firstTime = true; 
  }
  delay(200);              // wait 100ms for next reading
  last4 ='c', last3 ='c', last2 = 'c', last1 = 'c';
    

  if (!ble_connected()){
    readVal = 0x00;
    firstTime = true;
    digitalWrite(ledPin2, LOW);
  }
  
  // Allow BLE Shield to send/receive data
  ble_do_events();
  //digitalWrite(RED, LOW);
}
