import '../classes/usuario.dart';
import '../classes/api_call.dart';

void main() async{
  Usuario user = Usuario(servidor: 'simasat');
  user.setEmail("talesuriel@gmail.com");
  user.setSenha("123456");

  APICall api = APICall(null, null);
  dynamic r = await api.enviarLogin(user.toJson());
  if(r == null) {
    print("test failed :c");
    return;
  }

  Usuario logged = Usuario.fromJson(r);
  logged.realizarLogin(api.getToken());
  print("usuario logado:");
  print(logged);

  dynamic rm = await api.receberMotoristas();
  if(rm == null) {
    print("test failed :c");
    return;
  }
  print("\nlista de motoristas: ");
  print(rm);

  print("test success :D");
}