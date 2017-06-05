#include <Servo.h>
Servo myServo;

const int controlPin = 2;
const int servoPin = 9;

void setup(){
  pinMode(controlPin, INPUT);
  myServo.attach(servoPin);
  Serial.begin(9600);
  myServo.write(10); 
}
void loop(){
  if(digitalRead(controlPin) == HIGH) {
    Serial.println("ON");
    myServo.write(10); 
  } else {
    Serial.println("OFF");
    myServo.write(90); 
  }
}
