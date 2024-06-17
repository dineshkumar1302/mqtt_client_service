library mqtt_client_service;

import 'dart:math';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTClientService {
  String broker;
  String clientId;
  late MqttServerClient client;
  Function(String, String)? onMessageReceived;

  MQTTClientService(this.broker, this.clientId);

  void initializeMQTTClient({Function? onConnected}) {
    final random = Random();
    clientId = '$clientId-${random.nextInt(10000)}';

    client = MqttServerClient(broker, clientId);
    client.onConnected = () {
      if (onConnected != null) {
        onConnected();
      }
    };
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.onAutoReconnect = onAutoReconnect;
    client.onAutoReconnected = onAutoReconnected;
    client.pongCallback = pong;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;

    client.connect().then((value) {
      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        print('Connected');
      } else {
        print('Failed to connect');
      }
    });

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

      if (onMessageReceived != null) {
        onMessageReceived!(c[0].topic, payload);
      }
    });
  }

  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    print('Publishing to $topic: $message');
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }

  // MQTT event callbacks
  void onDisconnected() {
    client.disconnect();
    print('Disconnected');
  }

  void onSubscribed(String topic) {
    client.subscribe(topic, MqttQos.atMostOnce);
    print('Subscribed to $topic');
  }

  void onSubscribeFail(String topic) {
    print('Failed to subscribe $topic');
  }

  void unSubscribed(String topic) {
    client.unsubscribe(topic);
    print('Unsubscribed from $topic');
  }

  void onAutoReconnect() {
    print('Auto reconnect');
  }

  void onAutoReconnected() {
    print('Auto reconnected');
  }

  void pong() {
    print('Ping response client callback invoked');
  }
}

