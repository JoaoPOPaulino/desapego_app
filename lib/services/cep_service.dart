import 'dart:convert';
import 'package:http/http.dart' as http;

class CepService {
  static Future<Map<String, dynamic>> buscarCep(String cep) async {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cepLimpo.length != 8) {
      throw Exception('CEP inválido');
    }

    final url = Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Erro ao consultar CEP');
    }

    final data = jsonDecode(response.body);

    if (data['erro'] == true) {
      throw Exception('CEP não encontrado');
    }

    return data;
  }
}
