import 'package:http/http.dart';
import 'fetch.dart';

class APICall {
  String? server;
  String? token;
  Fetch fetch = Fetch();

  APICall(this.server, this.token);

  String getServer() {
    return server??'simasat';
  }

  void setServer(String server) {
    this.server = server;
  }

  String getToken() {
    return token??'';
  }

  void setToken(String token) {
    this.token = token;
  }

  dynamic enviarLogin(Map<String, dynamic> login) async {
    try {
      setServer(login['servidor']);
      
      String link = "https://" + getServer() + ".simagestor.com.br/api/api_auth.php/login";
      Map<String, dynamic> loginRequest = {};
      loginRequest['username'] = login['email'];
      loginRequest['password'] = login['senha'];
      
      dynamic responseLogin = await fetch.post(link, {}, loginRequest); 
      if(responseLogin == null) {
        throw new ClientException("erro no request");
      }

      dynamic data = responseLogin['data'];
      setToken(data['token']);
      
      dynamic motoristas = await receberMotoristas();
      String nome = 'unnamed';
      for(int i=0; i<motoristas.length ;i++) {
        if(motoristas[i]['id'] == data['user_id']) {
          nome = motoristas[i]['nome'];
        }
      }

      Map<String, dynamic> user = {};
      user['id'] = data['user_id'];
      user['nome'] = nome;
      user['email'] = login['email'];
      user['servidor'] = getServer();
      user['token'] = getToken();

      return user;
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  dynamic receberMotoristas() async {
    try {
      String link = "https://" + getServer() + ".simagestor.com.br/api/api_motoristas.php";
      Map<String, String> headers = {'Authorization': "Bearer " + getToken()};
      
      dynamic responseMotoristas = await fetch.get(link, headers);
      dynamic data = responseMotoristas['data'];
    
      return data;
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  /*bool enviarAbastecimento(Map<String, dynamic> abasecimento) {
    try {




    } catch(e) {
      print(e.toString());
      return false;
    }
  }*/
}