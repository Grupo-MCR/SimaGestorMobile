import 'dart:convert';
import 'package:http/http.dart' as http;

// Classe para fazer as comunicações com a API
class Fetch {
  // Atributo para fazer as transações com a API
  var client = http.Client();

  // Construtor da classe
  Fetch();

  // Método para fazer um fetch no modo GET
  Future<dynamic> get(String apiLink, Map<String, String> headers) async {
    var fetchUrl = Uri.parse(apiLink); // URL da API
    var fetchHeaders = headers; // Headers da requisição

    var response = await client.get(
      fetchUrl,
      headers: fetchHeaders,
    ); // Execução da requisição
    if (response.statusCode != 200) {
      print(response.body);
      print(response.statusCode);
      throw Exception(
        'request failed :p',
      ); // Lança erro se a requisição não for bem sucedida :P
    }
    return jsonDecode(response.body); // Retorno da resposta da requisição
  }

  //Método para fazer um fetch no modo POST
  Future<dynamic> post(
    String apiLink,
    Map<String, String> headers,
    dynamic body,
  ) async {
    var fetchUrl = Uri.parse(apiLink); // URL da API
    var fetchBody = json.encode(body); // Body da requisição
    var fetchHeaders = headers; // Headers da requisição

    var response = await client.post(
      fetchUrl,
      body: fetchBody,
      headers: fetchHeaders,
    ); // Execução da requisição
    if (response.statusCode != 200) {
      print(response.statusCode);
      throw Exception(
        'request failed :p',
      ); // Lança erro se a requisição não for bem sucedida :P
    }
    return jsonDecode(response.body); // Retorno da resposta da requisição
  }
}
