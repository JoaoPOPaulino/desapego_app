import 'dart:convert';
import 'package:http/http.dart' as http;

class IaService {
  static const String _apiKey = 'AIzaSyBU8ZP9LB3YWiN_7rqIqkKzxPxrwrjOSSg';

  static Future<Map<String, dynamic>> sugerirAnuncio({
    required String nome,
    required String descricao,
    required String qualidade,
  }) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent',
    );

    final prompt =
        '''
Você é um assistente para um aplicativo de desapego de usados.

Analise este item:
Nome: $nome
Descrição: $descricao
Qualidade: $qualidade

Responda somente em JSON válido, sem markdown:
{
  "categoria": "uma entre: Eletrônicos, Móveis, Roupas, Livros, Esportes, Outros",
  "preco": número estimado em reais ou null se parecer doação,
  "descricao": "descrição melhorada para anúncio"
}
''';

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'x-goog-api-key': _apiKey},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final texto = data['candidates'][0]['content']['parts'][0]['text'];

    return jsonDecode(texto);
  }
}
