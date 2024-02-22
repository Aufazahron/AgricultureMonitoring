// import 'dart:ffi';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MqttServerClient client = MqttServerClient('mqtt.antares.id', 'iot');
  String mqttPayload = 'No data';

  int temperature = 0;
  int humidity = 0;
  int batteryPercentage = 0;
  String gasCo = '0';
  String battVolt = '0';
  String windSpeed = '0';
  String rainDrop = '0';
  String kelembabanTanah = '0';

  @override
  void initState() {
    super.initState();

    // Inisialisasi koneksi MQTT dan langganan topik
    client.onConnected = _onConnected;

    // Connect ke broker
    _connect();
  }

  Future<void> _connect() async {
    try {
      await client.connect();
    } catch (e) {
      print('Error connecting to MQTT broker: $e');
    }
  }

  void _onConnected() {
    print('Connected to the broker');

    // Connect To Topic
    client.subscribe(
        '/oneM2M/resp/antares-cse/e08e0b16b2add3a1:ce17ab4326d9d010/json',
        MqttQos.atLeastOnce);
    // Menggunakan updates.listen untuk mendengarkan pembaruan klien
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      // Mendapatkan topik dari pesan
      final String topic = c[0].topic;
      // print('Received message on topic $topic: $payload');

      Map<String, dynamic> jsonData = json.decode(payload);
      Map<String, dynamic> pcData = jsonData["m2m:rsp"]["pc"]["m2m:cin"];
      String conData = pcData["con"];
      Map<String, dynamic> sensorData = json.decode(conData);
      // Menambahkan dataPoints dengan waktu sekarang dan nilai dari payload
      setState(() {
        mqttPayload = payload;
        temperature = sensorData["temperature"];
        humidity = sensorData["humidity"];
        batteryPercentage = sensorData["batteryPercentage"];
        gasCo = sensorData["gasCo"].toStringAsFixed(2);
        battVolt = sensorData["BattVolt"].toStringAsFixed(2);
        windSpeed = sensorData["windSpeed"].toStringAsFixed(2);
        rainDrop = sensorData["rainDrop"].toStringAsFixed(0);
        kelembabanTanah = sensorData["kelembabanTanah"].toStringAsFixed(0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Air Quality Monitoring'),
        backgroundColor: Colors.amberAccent,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(20)),
            height: 200,
            margin: EdgeInsets.all(15),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(border: Border.all()),
                  height: 100,
                )
              ],
            ),
          ),
          Text("Temperature: $temperature"),
          Text("Humidity: $humidity"),
          Text("Battery Percentage: $batteryPercentage"),
          Text("Gas CO: $gasCo"),
          Text("Battery Voltage: $battVolt"),
          Text("Wind Speed: $windSpeed"),
          Text("Rain Drop: $rainDrop"),
          Text("Soil Moisture: $kelembabanTanah"),
        ],
      ),
    );
  }
}
