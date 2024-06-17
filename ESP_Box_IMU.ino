#include <Arduino.h>
#include <ESP8266WiFi.h>
#include "PubSubClient.h"
#include <Adafruit_MMA8451.h>
#include <Adafruit_Sensor.h>
#include <ArduinoJson.h>
#include <Wire.h>


//Network parameters and MQTT server IP
char ssid[] = "IIoT_Box"; //iiot_case_1, iiot_case_2, iiot_case_3, iiot_case_4
const char* password =  "robotlab"; //the code for all the WiFis
const char* mqtt_server = "10.3.141.1"; //IP addr for all the cases

//Define the name of the ESP
String espName = "ESPBox2";

//MQTT
WiFiClient espClient;
PubSubClient client(espClient);

unsigned long startmillis;
unsigned long currentmillis = 1;
unsigned long oldmillis = 1;
const unsigned long period = 1000;
Adafruit_MMA8451 mma = Adafruit_MMA8451();


/********************************************************************** NETWORK FUNCTIONS ***************************************************************************/

// connect to network function
void connectNetwork(){
  delay(10);
  Serial.begin(115200);

  WiFi.hostname(espName.c_str());
  WiFi.begin(ssid, password);
  WiFi.mode(WIFI_STA);
 
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println(WiFi.status());
  }

  if (!mma.begin()) {
    Serial.println("Sensor init failed");
    while (1)
      yield();
  }
  mma.setRange(MMA8451_RANGE_8_G);
  Serial.println(WiFi.localIP());
  Serial.println("Connected to the WiFi network");
}

//Attempt to reconnect to MQTT server if the connection is lost
void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Create a random client ID
    String clientId = "ESP8266Client-";
    clientId += String(random(0xffff), HEX);
    // Attempt to connect
    if (client.connect(clientId.c_str())) {
      Serial.println("connected");
      // Once connected, publish an announcement...
      client.publish("outTopic", "hello world");
      // ... and resubscribe
      client.subscribe("inTopic");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

/********************************************************************** SENSOR FUNCTIONS ***************************************************************************/
void imu(){
  sensors_event_t a;
  mma.getEvent(&a);
  currentmillis = millis();
  //oldmillis = currentmillis;

  String jsonString;
  DynamicJsonDocument doc(1024);

  doc["sensor"] = "IMU";
  doc["timestamp"]   = "time";
  doc["milli"] = currentmillis;

  doc["acceleration"][0] = a.acceleration.x;
  doc["acceleration"][1] = a.acceleration.y;
  doc["acceleration"][2] = a.acceleration.z;

  serializeJson(doc, jsonString);
  //Serial.print("X: \t"); Serial.print(a.acceleration.x); Serial.print("\t");
  //Serial.print("Y: \t"); Serial.print(a.acceleration.y); Serial.print("\t");
  //Serial.print("Z: \t"); Serial.print(a.acceleration.z); Serial.print("\t");
  //Serial.println("m/s^2 ");
  //Serial.println(jsonString);
  String namePub = espName + "/imu";

  client.publish(namePub.c_str(), jsonString.c_str());
}




void setup() {

  connectNetwork();

  client.setServer(mqtt_server, 1883);
  startmillis = millis();
}

void loop() {
  if (!client.connected()){
    reconnect();
  }
  client.loop();
  
  while (millis()-currentmillis < 8){
    delay(1);
  }

  imu();

}
