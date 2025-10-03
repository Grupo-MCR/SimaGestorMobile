import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;

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

    var response = await client.get(fetchUrl, headers: fetchHeaders); // Execução da requisição
    if(response.statusCode != 200) {
      print(response.body);
      print(response.statusCode);
      throw Exception('request failed :p'); // Lança erro se a requisição não for bem sucedida :P
    }
    return jsonDecode(response.body); // Retorno da resposta da requisição
  }

  //Método para fazer um fetch no modo POST
  Future<dynamic> post(String apiLink, Map<String, String> headers, dynamic body,) async {
    var fetchUrl = Uri.parse(apiLink); // URL da API
    var fetchBody = json.encode(body); // Body da requisição
    var fetchHeaders = headers; // Headers da requisição

    var response = await client.post(fetchUrl, body: fetchBody, headers: fetchHeaders); // Execução da requisição
    if(response.statusCode != 200) {
      print(response.body);
      print(response.statusCode);
      throw Exception('request failed :p'); // Lança erro se a requisição não for bem sucedida :P
    }
    return jsonDecode(response.body); // Retorno da resposta da requisição
  }
  
  //Método para fazer um fetch do tipo MultipartFormData no modo POST
  Future<dynamic> multipartPost(String apiLink, Map<String, String> headers, Map<String, String> body, Map<String, String> files, Map<String, Map<String, String>> mediaTypes) async {
    var requestUrl = Uri.parse(apiLink); // Link da API
    var request = http.MultipartRequest('POST', requestUrl); // Declaração da requisição
    
    // Define os headers da requisição com base no map de headers passado 
    headers.forEach((key, value) {
      request.headers[key] = value;
    });

    // Define os campos de texto da requisição com base no map de body passado 
    body.forEach((key, value) {
      request.fields[key] = value;
    });


    // Define os campos de arquivos da requisição com base no map de arquivos e tipo de midia passadas
    files.forEach(await (key, value) async {
      request.files.add(await http.MultipartFile.fromPath(
      key, value,
      contentType: http_parser.MediaType(mediaTypes[key]?.keys.first??'image', mediaTypes[key]?.values.first??'*')));
    });

    // bloco try realiza a requisição
    try {
      var response = await request.send(); // Manda a requisição
      print(response.statusCode); // Faz um log do Status Code do retorno da requisição
      var body = await response.stream.bytesToString(); // Converte os bytes da resposta para uma string json
      return jsonDecode(body); // Retorna a resposta da requisição como um map
    } catch(e) {
      print(e.toString()); // Faz um log do erro
      throw Exception("request failed :p"); // Lança erro se a requisição não for bem sucedida :P
    }
  }

}

