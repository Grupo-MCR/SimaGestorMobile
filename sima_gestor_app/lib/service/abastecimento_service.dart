import 'package:sima_gestor_app/model/abastecimento.dart';
import 'package:sima_gestor_app/model/api_call.dart';

class AbastecimentoService {
  static Future<String> enviarAbastecimento(
    String servidor, 
    String token,
    Abastecimento abastecimento) async {
      if(servidor.isEmpty || token.isEmpty) {
        throw new Exception("Erro: não foi possível realizar conexão com o sistema");
      }
      if(!abastecimento.validarNull()) {
        throw new Exception("Erro: um ou mais campos não preenchidos");
      }
      APICall api = APICall(servidor, token);
      try {
        var respostaAPI = await api.enviarAbastecimento(abastecimento.buildAbastecimento());
        return respostaAPI;
      } catch (e) {
        throw new Exception(e.toString());
      }
  }
}