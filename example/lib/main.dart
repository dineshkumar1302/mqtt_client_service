import 'package:flutter/material.dart';
import 'package:mqtt_client_service/mqtt_client_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

  void onMessageReceived(String topic, String message) {
    setState(() {
      receivedMessages.add('Topic: $topic, Message: $message');
    });
  }

  @override
  void dispose() {
    mqttClientService.onDisconnected();
    super.dispose();
  }

  void handleSubscribe() {
    final topic = topicController.text;
    if (topic.isNotEmpty) {
      mqttClientService.onSubscribed(topic);
    }
  }

  void handleUnsubscribe() {
    final topic = topicController.text;
    if (topic.isNotEmpty) {
      mqttClientService.unSubscribed(topic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Client Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: topicController,
              decoration: const InputDecoration(labelText: 'Topic'),
            ),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleSubscribe,
              child: const Text('Subscribe'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleUnsubscribe,
              child: const Text('Unsubscribe'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                mqttClientService.publishMessage(
                  topicController.text,
                  messageController.text,
                );
              },
              child: const Text('Publish'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
