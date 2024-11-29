import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:sensor_uv_iot/mqt/MQTTService.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class NotificationData {
  final String name;
  final String aviso;
  final Color color;

  NotificationData({
    required this.name,
    required this.aviso,
    required this.color,
  });
}

class _MyWidgetState extends State<MyWidget> {
  String currentTime = '';
  String dayOfWeek = '';

  @override
  void initState() {
    super.initState();
    _updateTime(); // Chama a função de atualização imediatamente
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime(); // Atualiza a hora a cada 1 segundo
    });
  } // Função para atualizar a hora e o dia da semana

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      currentTime = "${now.hour}:${now.minute}:${now.second}";
      dayOfWeek = _getDayOfWeek(now.weekday); // Pega o nome do dia da semana
    });
  }

  // Função para mapear o número do dia da semana para o nome
  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Segunda-feira';
      case 2:
        return 'Terça-feira';
      case 3:
        return 'Quarta-feira';
      case 4:
        return 'Quinta-feira';
      case 5:
        return 'Sexta-feira';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return 'Desconhecido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cloud System',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 51, 51, 56),

        leading: const Icon(
          Icons.cloud,
          color: Colors.white,
        ), // Ícone no início do AppBar
      ),
      body: SafeArea(
        child: Consumer<MQTTService>(builder: (context, mqttService, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 51, 51, 56), // Azul escuro
                  Color.fromARGB(255, 21, 24, 26), // Azul claro
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            //  height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Container(
                //   padding: const EdgeInsets.all(20),
                //   child: Text(
                //     mqttService.latestMessage ?? 'Aguardando mensagem...',
                //     style: const TextStyle(color: Colors.white, fontSize: 18),
                //   ),
                // ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 119, 182, 253), // Azul escuro
                        Color.fromARGB(255, 0, 157, 255), // Azul claro
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                  margin: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Dia da semana
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.sunny,
                            color: Colors.white,
                            size: 120,
                          ),
                          const SizedBox(width: 8), // Espaço entre os textos
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dayOfWeek,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                              Text(currentTime,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 25)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mqttService.latestMessage?["temperatura"]
                                            .toString() ??
                                        '000',
                                    style: const TextStyle(
                                        fontSize: 50,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.circle_outlined,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "C",
                                        style: TextStyle(
                                            fontSize: 30, color: Colors.white),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(
                                Icons.lightbulb,
                                color: Colors.white,
                                size: 27,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                  mqttService.latestMessage?["lightIntensity"]
                                          .toString() ??
                                      '000',
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                "Luminosidade",
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(
                                Icons.water_drop_outlined,
                                color: Colors.white,
                                size: 27,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                  mqttService.latestMessage?["umidade"]
                                          .toString() ??
                                      '000',
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                "Umidade",
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          // Column(
                          //   children: [
                          //     const Icon(
                          //       Icons.cloud_queue,
                          //       color: Colors.white,
                          //       size: 27,
                          //     ),
                          //     const SizedBox(
                          //       height: 5,
                          //     ),
                          //     const Text(("awd"),
                          //         style: TextStyle(
                          //             color: Colors.white,
                          //             fontWeight: FontWeight.bold)),
                          //     Text(
                          //       "teste",
                          //       style: TextStyle(
                          //           color: Colors.grey[700],
                          //           fontWeight: FontWeight.bold),
                          //     )
                          //   ],
                          // )
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(15),
                  child: const Text(
                    "Informações",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: mqttService.listNotification.length,
                    itemBuilder: (context, index) {
                      final reverseIndex =
                          mqttService.listNotification.length - 1 - index;
                      final notification =
                          mqttService.listNotification[reverseIndex];
                      Color color = notification.color;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15), //
                        ),
                        child: ListTile(
                          subtitle: Text(notification.name),
                          title: Text(
                            notification.aviso,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                          leading: Container(
                            width: 50, // Define largura para o ícone
                            height: 50, // Define altura para o ícone
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(
                                  15), // Borda arredondada para o leading
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
