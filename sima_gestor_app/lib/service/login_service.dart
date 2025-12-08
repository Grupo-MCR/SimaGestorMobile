import 'package:http/http.dart';

import '../model/usuario.dart';
import 'api_service.dart';

class LoginService {
  static Future<Usuario> login(
    String email,
    String senha,
    String servidor,
  ) async {
    try {
      if (email.isEmpty || senha.isEmpty || servidor.isEmpty) {
        throw Exception("Preencha todos os campos!");
      }

      Usuario user = Usuario(servidor: servidor);
      user.setEmail(email);
      user.setSenha(senha);

      APIService api = APIService(null, null);
      dynamic r = await api.enviarLogin(user.toJson());

      if (r == null) {
        throw Exception("Falha no login. Verifique os dados.");
      }

      Usuario logged = Usuario.fromJson(r);
      logged.realizarLogin(api.getToken());
      return logged;
    } on ClientException catch(e) {
      print(e.toString());
      rethrow;
    }catch(e) {
      print(e.toString());
      rethrow;
    }
  }
}
