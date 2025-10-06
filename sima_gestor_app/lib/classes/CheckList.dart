import 'item_checklist.dart';

class CheckList {
  int? id;
  int? idVeiculo;
  int? idMotorista;
  String? nomeVerificador;
  String? assinaturaBase64;
  List<ItemCheckList> itens = [];

  // Construtor
  CheckList({
    this.id,
    this.idVeiculo,
    this.idMotorista,
    this.nomeVerificador,
    this.assinaturaBase64
  });

  bool validarNull() {
    if(idVeiculo == null ||
        idMotorista == null ||
        nomeVerificador == null || 
        assinaturaBase64 == null ||
        itens.isEmpty) {
      return false;
    }
    return true;
  }

  int? getId() {
    return id;
  }

  void setId(int id) {
    this.id = id;
  } 

  int? getIdVeiculo() {
    return idVeiculo;
  }

  void setIdVeiculo(int idVeiculo) {
    this.idVeiculo = idVeiculo;
  }

  int? getIdMotorista() {
    return idMotorista;
  }

  void setIdMotoristas(int idMotorista) {
    this.idMotorista = idMotorista;
  }

  String? getNomeVerificador() {
    return nomeVerificador;
  }

  void setNomeVerificador(String nomeVerificador) {
    this.nomeVerificador = nomeVerificador;
  }

  String? getAssinaturaBase64() {
    return assinaturaBase64;
  }

  void setAssinaturaBase64(String assinaturaBase64) {
    this.assinaturaBase64 = assinaturaBase64;
  }

  List<ItemCheckList> getItensChecklist() {
    return itens;
  }

  void addItensChecklist(ItemCheckList item) {
    itens.add(item);
  }

  Map<String, dynamic> buildChecklist() {
    if(validarNull() == false) {
      throw new ArgumentError.notNull("argumentos nulos");
    }
    Map<String, dynamic> checklist = {};
    checklist['vehicle_id'] = idVeiculo;
    checklist['driver_id'] = idMotorista;
    checklist['checker_name'] = nomeVerificador;
    checklist['signature'] = assinaturaBase64;
    for(int i=0; i<itens.length; i++) {
      Map<String, dynamic> item = itens[i].buildItem();
      checklist["items[" + item['id'].toString() + "][result]"]= item['result'];
      checklist["items[" + item['id'].toString() + "][comments]"]= item['comments'];
      if(item['result'] ==  "not_ok") {
        checklist["items[" + item['id'].toString() + "][photo]"]= item['photo'];
      }
    }
    return checklist;
  }

  @override
  String toString() {
    return 'CheckList{id: $id, idVeiculo: $idVeiculo, idMotorista: $idMotorista, nomeVerificador: $nomeVerificador, assinaturaBase64: $assinaturaBase64, itens: $itens}';
  }
}