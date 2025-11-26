import 'package:sima_gestor_app/model/abastecimento.dart';
import 'package:sima_gestor_app/model/api_call.dart';

class AbastecimentoService {
  static Future<String> enviarAbastecimento(
    String servidor, 
    String token,
    Abastecimento abastecimento) async {
      if(servidor.isEmpty || token.isEmpty) {
        throw Exception("Erro: não foi possível realizar conexão com o sistema");
      }
      abastecimento.validarAll();
      APICall api = APICall(servidor, token);
      try {
        var respostaAPI = await api.enviarAbastecimento(abastecimento.buildAbastecimento());
        return respostaAPI;
      } catch (e) {
        throw Exception(e.toString());
      }
  }
}