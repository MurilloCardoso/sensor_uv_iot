import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:math';

import 'package:sensor_uv_iot/Screens/Home.dart';

class MQTTService with ChangeNotifier {
  late MqttServerClient client;
  final String broker = '172.22.20.60';
  final int port = 1883;
  final String topic =
      'trabalhotopdocursodecienciasdacomputacaounescuniversidadedoextremosulcatarinense';

  Map<String, dynamic>? latestMessage; // Armazena a última mensagem recebida
  List<NotificationData> listNotification = [];
  Function(bool)? onConnectionStatusChanged;

  MQTTService() {
    final String clientId = _generateRandomClientId();
    client = MqttServerClient.withPort(broker, clientId, port);
    client.logging(on: true);
    client.keepAlivePeriod = 20;

    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.onUnsubscribed = onUnsubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;
  }

  String _generateRandomClientId() {
    final random = Random();
    return 'client-${random.nextInt(10000)}';
  }

  Future<void> connect() async {
    try {
      await client.connect();
    } catch (e) {
      print('Erro ao conectar: $e');
      client.disconnect();
      onConnectionStatusChanged?.call(false);
      return;
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      print('Conectado ao broker');
      onConnectionStatusChanged?.call(true);
      client.subscribe(topic, MqttQos.atMostOnce);
    } else {
      print('Falha ao conectar: ${client.connectionStatus}');
      onConnectionStatusChanged?.call(false);
    }

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> events) {
      final MqttPublishMessage recMess =
          events[0].payload as MqttPublishMessage;
      final String payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print("Mensagem: " + payload);
      // Chama a função para processar a mensagem
      //   processMessage(payload);
      latestMessage = jsonDecode(payload);

      // Verificar Temperatura
      if (latestMessage?["temperatura"] > 25 &&
          latestMessage?["temperatura"] <= 27) {
        listNotification.add(NotificationData(
          name: 'Temperatura Agradável',
          aviso: 'A temperatura está fora do ideal, mas ainda aceitável.',
          color: const Color.fromARGB(255, 236, 236, 175),
        ));
      } else if (latestMessage?["temperatura"] > 27 &&
          latestMessage?["temperatura"] <= 30) {
        listNotification.add(NotificationData(
          name: 'Temperatura Média',
          aviso: 'Alerta de temperatura! Hidrate-se.',
          color: const Color.fromARGB(255, 236, 175, 84),
        ));
      } else if (latestMessage?["temperatura"] > 30) {
        listNotification.add(NotificationData(
          name: 'Temperatura Alta',
          aviso: 'Temperatura muito alta! Busque uma sombra imediatamente.',
          color: const Color.fromARGB(255, 236, 84, 84),
        ));
      }

      // Verificar Luminosidade
      if (latestMessage?["lightIntensity"] > 20 &&
          latestMessage?["lightIntensity"] <= 25) {
        listNotification.add(NotificationData(
          name: 'Luminosidade Baixa',
          aviso: 'A luz está um pouco baixa, mas ainda aceitável.',
          color: const Color.fromARGB(255, 175, 236, 175),
        ));
      } else if (latestMessage?["lightIntensity"] > 25 &&
          latestMessage?["lightIntensity"] <= 30) {
        listNotification.add(NotificationData(
          name: 'Luminosidade Moderada',
          aviso: 'A luminosidade está alta, use proteção para os olhos.',
          color: const Color.fromARGB(255, 236, 175, 84),
        ));
      } else if (latestMessage?["lightIntensity"] > 30) {
        listNotification.add(NotificationData(
          name: 'Luminosidade Intensa',
          aviso: 'Luminosidade muito intensa! Evite exposição prolongada.',
          color: const Color.fromARGB(255, 236, 84, 84),
        ));
      }

      // Verificar Umidade
      if (latestMessage?["umidade"] > 40 && latestMessage?["umidade"] <= 50) {
        listNotification.add(NotificationData(
          name: 'Umidade Agradável',
          aviso: 'A umidade está levemente fora do ideal, mas ainda aceitável.',
          color: const Color.fromARGB(255, 175, 236, 236),
        ));
      } else if (latestMessage?["umidade"] > 50 &&
          latestMessage?["umidade"] <= 60) {
        listNotification.add(NotificationData(
          name: 'Umidade Moderada',
          aviso: 'A umidade está alta, pode causar desconforto.',
          color: const Color.fromARGB(255, 236, 175, 84),
        ));
      } else if (latestMessage?["umidade"] > 60) {
        listNotification.add(NotificationData(
          name: 'Umidade Alta',
          aviso: 'Umidade muito alta! Pode causar dificuldade respiratória.',
          color: const Color.fromARGB(255, 236, 84, 84),
        ));
      }

      notifyListeners(); // Notifica os ouvintes
    });
  }

  void onConnected() {
    print('Conectado ao broker!');
    onConnectionStatusChanged?.call(true);
  }

  void onDisconnected() {
    print('Desconectado do broker');
    onConnectionStatusChanged?.call(false);
  }

  void onSubscribed(String topic) => print('Inscrito no tópico: $topic');
  void onUnsubscribed(String? topic) =>
      print('Cancelou inscrição no tópico: $topic');
  void onSubscribeFail(String topic) =>
      print('Falha ao se inscrever no tópico: $topic');
  void pong() => print('Ping recebido do broker');
}
