import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final String server = 'mqtt.things.ph';
  final int port = 1883;
  final String topic = 'RasPiTransPlantMQTT';
  String clientId = '64cd098d6f6b73d7c2f40ad9'; // Replace 'your_client_id' with your actual client ID

  MqttServerClient client = MqttServerClient('mqtt.things.ph', '64cd098d6f6b73d7c2f40ad9');

  double temperature = 0.0;
  double humidity = 0.0;
  double pressure = 0.0;

  Future<void> connect(String username, String password) async {
    try {
      client.logging(on: true);

      final MqttConnectMessage connectMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .authenticateAs('64c14253811ec75105c1948a', 'QuRHxlbi8RDbkv7Nkq77N3Ps') // Set the username and password here
          .withWillTopic(topic)
          .withWillMessage('Disconnected')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      client.connectionMessage = connectMessage;

      await client.connect();
      print('Connected to MQTT broker');
      subscribeToTopic();
    } catch (e) {
      print('Connection failed: $e');
    }
  }

  void subscribeToTopic() {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.subscribe(topic, MqttQos.atLeastOnce);
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        final MqttPublishMessage message = messages[0].payload as MqttPublishMessage;
        final String payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message!);
        print('Received message: $payload from topic: ${message.variableHeader!.topicName}');
        updateSensorData(payload);
      });
    }
  }

  void updateSensorData(String payload) {
    // Assuming the payload is in the format "temperature,humidity,pressure"
    List<String> sensorData = payload.split(',');
    if (sensorData.length == 3) {
      try {
        temperature = double.parse(sensorData[0]);
        humidity = double.parse(sensorData[1]);
        pressure = double.parse(sensorData[2]);
      } catch (e) {
        print('Error parsing sensor data: $e');
      }
    }
  }

  void publishMessage(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('Published message: $message to topic: $topic');
    }
  }

  void disconnect() {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.disconnect();
      print('Disconnected from MQTT broker');
    }
  }
}