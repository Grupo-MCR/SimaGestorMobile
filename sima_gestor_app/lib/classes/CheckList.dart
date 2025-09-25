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
      checklist["items[" + item['id'] + "][result]"]= item['result'];
      checklist["items[" + item['id'] + "][comments]"]= item['comments'];
      if(item['result'] ==  "not_ok") {
        checklist["items[" + item['id'] + "][photo]"]= item['photo'];
      }
    }
    return checklist;
  }

  @override
  String toString() {
    return 'CheckList{id: $id, idVeiculo: $idVeiculo, idMotorista: $idMotorista, nomeVerificador: $nomeVerificador, assinaturaBase64: $assinaturaBase64, itens: $itens}';
  }
}