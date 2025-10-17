import 'package:sima_gestor_app/model/despesas.dart';
import 'package:sima_gestor_app/model/api_call.dart';

class DespesaService {
  static Future<String> enviarDespesa(
    String servidor, 
    String token,
    Despesa despesa) async {
      if(servidor.isEmpty || token.isEmpty) {
        throw new Exception("Erro: não foi possível realizar conexão com o sistema");
      }
      if(!despesa.validarNull()) {
        throw new Exception("Erro: um ou mais campos não preenchidos");
      }
      APICall api = APICall(servidor, token);
      try {
        var respostaAPI = await api.enviarDespesa(despesa.buildDespesa());
        return respostaAPI;
      } catch (e) {
        throw new Exception(e.toString());
      }
  }
}