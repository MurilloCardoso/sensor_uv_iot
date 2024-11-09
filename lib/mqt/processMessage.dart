import 'dart:convert';

void processMessage(String message) {
  try {
    // Decodifica a string JSON para um mapa
    final Map<String, dynamic> data = jsonDecode(message);

    // Acessa os valores com as chaves
    final ldrLevel = data['ldrLevel'];
    final voltageLDR = data['voltageLDR'];
    final lightIntensity = data['lightIntensity'];
    final temperatura = data['temperatura'];
    final umidade = data['umidade'];

    // Exibe os valores (ou use-os como preferir)
    print('LDR Level: $ldrLevel');
    print('Voltage LDR: $voltageLDR');
    print('Light Intensity: $lightIntensity');
    print('Temperatura: $temperatura');
    print('Umidade: $umidade');
  } catch (e) {
    print('Erro ao processar a mensagem: $e');
  }
}
