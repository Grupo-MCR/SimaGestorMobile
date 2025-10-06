import '../classes/usuario.dart';
import '../classes/api_call.dart';

class LoginService {
  static Future<Usuario> login(
    String email,
    String senha,
    String servidor,
  ) async {
    if (email.isEmpty || senha.isEmpty || servidor.isEmpty) {
      throw Exception("Preencha todos os campos!");
    }

    Usuario user = Usuario(servidor: servidor);
    user.setEmail(email);
    user.setSenha(senha);

    APICall api = APICall(null, null);
    dynamic r = await api.enviarLogin(user.toJson());

    if (r == null) {
      throw Exception("Falha no login. Verifique os dados.");
    }

    Usuario logged = Usuario.fromJson(r);
    logged.realizarLogin(api.getToken());

    return logged;
  }
}
