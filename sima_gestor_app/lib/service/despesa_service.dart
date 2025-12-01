import 'package:sima_gestor_app/model/despesas.dart';
import 'package:sima_gestor_app/service/api_service.dart';

class DespesaService {
  static Future<String> enviarDespesa(
    String servidor, 
    String token,
    Despesa despesa) async {
      if(servidor.isEmpty || token.isEmpty) {
        throw Exception("Erro: não foi possível realizar conexão com o sistema");
      }
      if(!despesa.validarNull()) {
        throw Exception("Erro: um ou mais campos não preenchidos");
      }
      APIService api = APIService(servidor, token);
      try {
        var respostaAPI = await api.enviarDespesa(despesa.buildDespesa());
        return respostaAPI;
      } catch (e) {
        throw Exception(e.toString());
      }
  }
}