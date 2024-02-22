#include <LoRa.h>
#include <AntaresESPMQTT.h>

// inisialisasi Lora
#define SS_PIN 5
#define RST_PIN 0
#define DI0_PIN 2
#define BAND 915E6

// inisialisasi Wifi
#define WIFISSID "azrniot"         
#define PASSWORD "wkwkwkwk"

// inisialisasi Antares
#define ACCESSKEY "e08e0b16b2add3a1:ce17ab4326d9d010"
#define projectName "iotedgecomputing"   // Name of the application created in Antares
#define deviceName "Lynx-receiver"     // Name of the device created in Antares

AntaresESPMQTT antares(ACCESSKEY);

void setup() {
  Serial.begin(9600);
  // Setup Antares
  antares.setDebug(true);
  antares.wifiConnection(WIFISSID, PASSWORD);
  antares.setMqttServer();

  while (!Serial);

  LoRa.setPins(SS_PIN, RST_PIN, DI0_PIN);

  if (!LoRa.begin(BAND)) {
    Serial.println("Starting LoRa failed!");
    while (1);
  }
  Serial.println("LoRa Initializing OK!");

  // Mengatur pin DIO0 sebagai input
  pinMode(DI0_PIN, INPUT);
}

void loop() {
  antares.checkMqttConnection();
  // Menunggu sampai paket diterima
  if (LoRa.parsePacket()) {
    Serial.println("Packet received:");

    // Membaca data yang diterima
    String dataReceived = "";
    while (LoRa.available()) {
      dataReceived += (char)LoRa.read();
    }
    sendConfirmation();

    // Memisahkan nilai suhu dan kelembapan
    int humidity, temperature, batteryPercentage;
    float gasCo, BattVolt, windSpeed, rainDrop, kelembabanTanah;
    sscanf(dataReceived.c_str(), "%d,%d,%d,%f,%f,%f,%f,%f", &humidity, &temperature, &batteryPercentage, &gasCo, &BattVolt, &windSpeed, &rainDrop, &kelembabanTanah);

    // Publish Antares MQTT
    antares.add("temperature", temperature);
    antares.add("humidity", humidity);
    antares.add("batteryPercentage", batteryPercentage);
    antares.add("gasCo", gasCo);
    antares.add("BattVolt", BattVolt);
    antares.add("windSpeed", windSpeed);
    antares.add("rainDrop", rainDrop);
    antares.add("kelembabanTanah", kelembabanTanah);
    antares.publish(projectName, deviceName);


    // Menampilkan nilai-nilai variabel
    // Serial.print("Humidity: ");
    // Serial.println(humidity);
    // Serial.print("Temperature: ");
    // Serial.println(temperature);
    // Serial.print("Battery Percentage: ");
    // Serial.println(batteryPercentage);
    // Serial.print("Gas CO: ");
    // Serial.println(gasCo);
    // Serial.print("Battery Voltage: ");
    // Serial.println(BattVolt);
    // Serial.print("Wind Speed: ");
    // Serial.println(windSpeed);
    // Serial.print("Rain Drop: ");
    // Serial.println(rainDrop);
    // Serial.print("Soil Moisture: ");
    // Serial.println(kelembabanTanah);
  }
}


void sendConfirmation() {
  LoRa.beginPacket();
  LoRa.print("LoraAzrnConfirmUwU");
  LoRa.endPacket();
  Serial.println("Confirmation sent to transmitter!");
}
