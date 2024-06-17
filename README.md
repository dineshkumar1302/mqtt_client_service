# mqtt_client_service

Custom MQTT Client Service with MQTT Client

## Features

 - Easily send and receive messages

## Getting started

To use this package, add mqtt_client_service as a dependency in your pubspec.yaml file.

## Usage

For example:

```dart
    late MQTTClientService mqttClientService;
    final String broker = 'broker.emqx.io';
    final String clientId = 'mqttx_3ced2008';
    final TextEditingController topicController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    List<String> receivedMessages = []; // Store received messages
    Set<String> subscribedTopics = {}; // Track subscribed topics

    @override
    void initState() {
      super.initState();
      mqttClientService = MQTTClientService(broker, clientId);
      mqttClientService.onMessageReceived = onMessageReceived;
      mqttClientService.initializeMQTTClient();
    }

    @override
    void dispose() {
      mqttClientService.onDisconnected();
      super.dispose();
    }

    ElevatedButton(
      onPressed: () {
        mqttClientService.publishMessage(
          topicController.text,
          messageController.text,
        );
      },
      child: const Text('Publish'),
    ),

    ListView.builder(
      itemCount: receivedMessages.length,
      itemBuilder: (context, index) {
        final messageData = receivedMessages[index];
        print("Received Message : $messageData");
        // Parse the received message
        final parts = messageData.split(', ');
        final topic = parts[0].substring('Topic: '.length);
        final message = parts[1].substring('Message: '.length);
        return ListTile(
          title: Row(
            children: [
              Expanded(
              child: Text(topic),
              ),
              Expanded(
              child: Text(message),
              ),
            ],
         ),
      );
    },
  )
```
