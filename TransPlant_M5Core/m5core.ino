  #include <Adafruit_TSL2591.h>
  #include <Wire.h>
  #include <WiFi.h>
  #include <PubSubClient.h>
  #include <ArduinoJson.h>
  #include <M5Core2.h>
  
  #define ADC1 35
  #define dry 2594
  #define wet 1119
  
  
  WiFiClient espClient;
  PubSubClient client(espClient);
  
  // Configure the name and password of the connected wifi and your MQTT Serve host. 
  const char* ssid = "SG4-3202";
  const char* password = "SG4-3202";
  const char* mqtt_server = "mqtt.things.ph";
  
  Adafruit_TSL2591 tsl = Adafruit_TSL2591(2591); //I2C
  
  StaticJsonDocument<5000> payload;
  StaticJsonDocument<5000> payload_fields;
  
  char combo[200];
  unsigned long lastMsg = 0;
  #define MSG_BUFFER_SIZE (50)
  char msg[MSG_BUFFER_SIZE];


  int facestatus = 0;


  
  float moisture = 0;
  float lux = 0;
  
  void setupWifi();
  void callback(char* topic, byte* payload, unsigned int length);
  void reConnect();


  void setupflower(){
    //petals
    M5.Lcd.fillCircle(130, 95, 30, PINK);
    M5.Lcd.fillCircle(160, 70, 30, PURPLE);
    M5.Lcd.fillCircle(190, 95, 30, PINK);
    M5.Lcd.fillCircle(130, 135, 30, PURPLE);
    M5.Lcd.fillCircle(160, 150, 30, PINK);
    M5.Lcd.fillCircle(190, 135, 30, PURPLE);
    
    M5.Lcd.fillCircle(160, 110, 30, YELLOW); // Center of the flower
  }


  void sadflower(){
    M5.Lcd.fillCircle(150, 105, 4, BLACK);   // Left eye
    M5.Lcd.fillCircle(170, 105, 4, BLACK);   // Right eye
  
    M5.Lcd.drawLine(152, 115, 168, 115, BLACK); // Mouth
    M5.Lcd.drawLine(152, 115, 152, 119, BLACK); // Mouth
    M5.Lcd.drawLine(168, 115, 168, 119, BLACK); // Mouth 
  }


  void deadflower(){
    M5.Lcd.drawLine(150, 95, 157, 102, BLACK); // Left eye
    M5.Lcd.drawLine(151, 95, 158, 102, BLACK); // Left eye
    M5.Lcd.drawLine(150, 102, 157, 95, BLACK); // Right eye
    M5.Lcd.drawLine(151, 102, 157, 95, BLACK); // Right eye


    M5.Lcd.drawLine(165, 95, 172, 102, BLACK); // Left "X" eye
    M5.Lcd.drawLine(166, 95, 172, 102, BLACK); // Left "X" eye
    M5.Lcd.drawLine(165, 102, 172, 95, BLACK); // Right "X" eye
    M5.Lcd.drawLine(166, 102, 172, 95, BLACK); // Right "X" eye


    M5.Lcd.drawLine(150, 115, 170, 115, BLACK); // Mouth
  }




  void happyflower(){
    M5.Lcd.fillCircle(150, 105, 4, BLACK);   // Left eye
    M5.Lcd.fillCircle(170, 105, 4, BLACK);   // Right eye
    M5.Lcd.drawLine(152, 120, 168, 120, BLACK); // Mouth
    M5.Lcd.drawLine(153, 120, 168, 120, BLACK); // Mouth
    M5.Lcd.drawLine(154, 120, 168, 120, BLACK); // Mouth


    M5.Lcd.drawLine(152, 120, 152, 115, BLACK); // Mouth
    M5.Lcd.drawLine(168, 120, 168, 115, BLACK); // Mouth


  }
  void setup() {
    M5.Lcd.fillScreen(GREENYELLOW); // Clear the screen with black color


    M5.begin();
    Serial.begin(9600);
    setupWifi();
    client.setServer(mqtt_server,1883);  //Sets the server details. 
    client.setCallback(callback); //Sets the message callback function.  
  
    if(tsl.begin())
    {
      Serial.println(F("Found a TSL2591 sensor"));
      Serial.print("Light Level =");
    }
    else {
      Serial.println("Could not find a valid light sensor, check wiring!");
      while (1);
    }
  
    tsl.setGain(TSL2591_GAIN_MED);                 // Set sensor gain to 25x
    tsl.setTiming(TSL2591_INTEGRATIONTIME_300MS);  // Set sensor integration time to 300 ms
    setupflower();


  }
  
  int count = 0;
  void loop() {
    if (!client.connected()) {
      reConnect();
    }
    client.loop();  
  
    float sensor = analogRead(ADC1);
    float percentage = (100 - (((sensor - wet)/(dry-wet))*100));
  
    uint32_t tsl2591_data = tsl.getFullLuminosity();   // Get CH0 & CH1 data from the sensor (two 16-bit registers)
    uint16_t ir, ir_visible;
    ir = tsl2591_data >> 16;              
    ir_visible = tsl2591_data & 0xFFFF;   
    float lux = tsl.calculateLux(ir_visible, ir);   // Calculate light lux value
  
//    M5.Lcd.println(lux, 6);
//    count++;
//    if(count >= 20){
//      count = 0;
//      M5.Lcd.clear();
//      M5.Lcd.setCursor(0, 0);
   // }
  //  // Print light lux on the LCD
  //  Serial.print(lux, 6);
  //  Serial.print( " Lux  " );
  // 
    // Print light lux on serial monitor
    Serial.print(F("Light Level = "));
    Serial.print(lux, 6);
    Serial.println( "Lux" );
    
    delay(500);   // wait half a second
    Serial.print("\n");
    Serial.print(percentage);
    Serial.print("%");
    delay(300);
    
    unsigned long now = millis(); 
    if (now - lastMsg > 5000) {
      lastMsg = now;


      if(percentage >= 20 && percentage<= 60){
        if (lux >=500 && lux<= 1000){
          //happy face
          facestatus = 0;
          delay(5000);
          
          M5.Lcd.fillScreen(0x559E); 
          setupflower();
          happyflower();
  
        }
        else{
          //sad face
          facestatus = 1;
          delay(5000);
          M5.Lcd.fillScreen(DARKGREY); 
          setupflower();  
          sadflower();
        }
      }
      else{
        if(lux>=300 && lux<=1000){
          //sad face
          facestatus = 1;
          delay(5000);
          M5.Lcd.fillScreen(DARKGREY); 
          setupflower();
          sadflower();
        }
        else{
          //dead face
          facestatus = 2;  
          delay(5000);
          M5.Lcd.fillScreen(RED); 
          setupflower();
          deadflower();
        }
      }
  
      payload_fields["moisture"] = percentage;
      payload_fields["light"] = lux;
      payload_fields["payload_fields"] = 1;
      payload_fields["flower_face"] = facestatus;
  
      payload["hardware_serial"] = "RasPiTransPlantMQTT";
      payload["payload_fields"] = payload_fields;
  
     // serializeJson(payload, Serial);
      serializeJson(payload, combo);
      client.publish("RasPiTransPlantMQTT", combo);
      Serial.printf("Message sent %s", combo);
      //Serial.println(combo);
    }






    
  }
  
  void setupWifi() {
    delay(10);
    Serial.printf("Connecting to %s", ssid);
    WiFi.mode(
        WIFI_STA);  //Set the mode to   station mode.  
    WiFi.begin(ssid, password);  //Start Wifi connection.  
  
    while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.print(".");
    }
    Serial.printf("\nSuccess\n");
  }
  
  void callback(char* topic, byte* payload, unsigned int length) {
    Serial.print("Message arrived [");
    Serial.print(topic);
    Serial.print("] ");
  
    String message;
  
    for (int i = 0; i < length; i++) {
      Serial.print((char)payload[i]);
      message += (char)payload[i]; 
    }
    Serial.println();
  }
  
  void reConnect() {
    while (!client.connected()) {
      Serial.print("Attempting MQTT connection...");
      // Create a random client ID. 
      String clientId = "M5Stack-";
      clientId += String(random(0xffff), HEX);
      // Attempt to connect.  
      String username = "64c14253811ec75105c1948a";
      String password = "QuRHxlbi8RDbkv7Nkq77N3Ps";
  
      // client.connect (clientID, Username, Password)
      if (client.connect(clientId.c_str(), username.c_str(), password.c_str())) {
        Serial.printf("\nSuccess\n");
        client.subscribe("RasPiTransPlantMQTT");
      } 
      else {
        Serial.print("failed, rc=");
        Serial.print(client.state());
        Serial.println("try again in 5 seconds");
        delay(5000);
      }
    }
  }



