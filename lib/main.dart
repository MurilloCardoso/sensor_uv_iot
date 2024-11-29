import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensor_uv_iot/Screens/Home.dart';
import 'package:sensor_uv_iot/mqt/MQTTService.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MQTTService mqttService;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    mqttService = MQTTService();
    mqttService.onConnectionStatusChanged = (status) {
      setState(() {
        isConnected = status;
      });
    };
    mqttService.connect();
  }

  @override
  void dispose() {
    mqttService.client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: mqttService,
      child: MaterialApp(
        home: isConnected ? const MyWidget() : DisconnectedScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class DisconnectedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 58, 58, 58), // Azul escuro
              Color.fromARGB(255, 14, 17, 185), // Azul claro
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Centraliza verticalmente
            crossAxisAlignment:
                CrossAxisAlignment.center, // Centraliza horizontalmente
            children: [
              Column(
                children: [
                  Icon(
                    Icons.signal_wifi_connected_no_internet_4_rounded,
                    size: 80,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ],
              ),
              SizedBox(height: 20), // Espaçamento entre o ícone e o texto
              Text(
                'Desconectado',
                style: TextStyle(
                    fontSize: 22, color: Color.fromARGB(255, 255, 255, 255)),
              ),
              Text(
                "Broker MQTT",
                style: TextStyle(
                    fontSize: 22, color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
