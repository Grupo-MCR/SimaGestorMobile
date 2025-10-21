import 'package:http/http.dart';
import 'package:sima_gestor_app/model/item_checklist.dart';
import 'package:sima_gestor_app/model/usuario.dart';
import 'package:sima_gestor_app/model/veiculo.dart';
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
      if(motoristas != null) {
        for(int i=0; i<motoristas.length ;i++) {
          if(motoristas[i].getId() == data['user_id']) {
            nome = motoristas[i]['nome'];
          }
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
      List<dynamic> data = responseMotoristas['data'];

      List<Usuario> motoristas = [];
      data.forEach((item) {
        item['servidor'] = getServer();
        motoristas.add(Usuario.fromJson(item));
      });
      
      return motoristas;
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  dynamic receberVeiculos() async {
    try {
      String link = "https://" + getServer() + ".simagestor.com.br/api/api_veiculos.php";
      Map<String, String> headers = {'Authorization': "Bearer " + getToken()};

      dynamic responseVeiculos = await fetch.get(link, headers);
      List<dynamic> data = responseVeiculos['data'];

      List<Veiculo> veiculos = [];
      data.forEach((item) {
        veiculos.add(Veiculo.fromJson(item));
      });

      return veiculos;
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  dynamic enviarAbastecimento(Map<String, dynamic> abastecimento) async {
    try {
      String link = "https://" + getServer() + ".simagestor.com.br/api/api_abastecimento.php";
      Map<String, String> headers = {'Authorization': "Bearer " + getToken()};      

      dynamic responseAbastecimento = await fetch.post(link, headers, abastecimento);
    
      return responseAbastecimento['message'];
    } catch(e) {
      throw new Exception(e.toString());
    }
  }

  dynamic enviarDespesa(Map<String, dynamic> despesa) async {
    try {
      String link = "https://" + getServer() + ".simagestor.com.br/api/api_despesas.php";
      Map<String, String> headers = {'Authorization': "Bearer " + getToken()};
      Map<String, String> body = {};
      despesa.forEach((key, value) {
        body[key] = value.toString();
      });

      dynamic responseDespesa = await fetch.multipartPost(link, headers, body, {}, {});
      return responseDespesa['message'];
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // Método para retornar uma lista com os itens de chelist do template do (id)véiculo passado
  dynamic receberItensChecklist(int idVeiculo) async {
    try {
      String link = "https://" + getServer()+ ".simagestor.com.br/api/api_checklist.php/templates?vehicle_id=" + idVeiculo.toString();
      Map<String, String> headers = {'Authorization': "Bearer " + getToken()};
        
      dynamic responseItensChecklist = await fetch.get(link, headers);
      List<dynamic> data = responseItensChecklist['data'];
      
      List<ItemCheckList> itens = [];
      data.forEach((item) {
        itens.add(ItemCheckList.fromJson(item));
      });

      return itens;   
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  dynamic enviarChecklist(Map<String, dynamic> checklist) async {
    try {
      String link = "https://" + getServer() + ".simagestor.com.br/api/api_checklist";
      Map<String, String> headers = {'Authorization': "Bearer " + getToken()};
      Map<String, String> fieldsBody = {};
      Map<String, String> filesBody = {};
      Map<String, Map<String, String>> midiaTypes = {};
      checklist.forEach((key, value) {
        if(key.contains("photo")) {
          filesBody[key] = value;
          midiaTypes[key] = {'image':'*'};
        } else {
          fieldsBody[key] = value.toString();
        }
      });

      dynamic responseChecklist = await fetch.multipartPost(link, headers, fieldsBody, filesBody, midiaTypes);

      return responseChecklist['message'];
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

}