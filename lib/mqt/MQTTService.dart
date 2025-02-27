import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:math';

class MQTTService with ChangeNotifier {
  late MqttServerClient client;
  final String broker = '172.22.20.60';
  final int port = 1883;
  final String topic =
      'trabalhotopdocursodecienciasdacomputacaounescuniversidadedoextremosulcatarinense';

  Map<String, dynamic>? latestMessage; // Armazena a última mensagem recebida

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
