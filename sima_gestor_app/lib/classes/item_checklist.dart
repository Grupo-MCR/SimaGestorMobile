import 'dart:io';

class ItemCheckList {
  int? id;
  String? nome;
  String? comentario;
  File? foto;
  bool status = false;

  // Construtor
  ItemCheckList({
    this.id,
    this.nome,
  });

  factory ItemCheckList.fromJson(Map<String, dynamic> json) {
    return ItemCheckList(
      id: json['id'] as int?,
      nome: json['item_name'] as String?,
    );
  }

  int? getId() {
    return id;
  }

  void setId(int id) {
    this.id = id;
  }

  String? getNome() {
    return nome;
  }

  void setNome(String nome) {
    this.nome = nome;
  }

  String? getComentario() {
    return comentario;
  }

  void setComentario(String comentario) {
    this.comentario = comentario;
  }

  File? getFoto() {
    return foto;
  }

  void setFoto(File foto) {
    this.foto = foto;
  }

  bool validarNull() {
    // Valida se os campos obrigatórios são nulos
    if(id == null || nome == null) {
      return false;
    }
    // Valida se os campos obrigatórios quando o status é falso são nulos
    if(status == false && (comentario == null || foto == null)) {
      return false;
    }
    return true;
  }

  // Método para alterar status
  void alterarStatus() {
    status = status==false?true:false;
  }

  // Metodo para definir resposta para API com base no status
  String getStatus() {
    return status==false?"ok":"not_ok";
  }

  // Retorna um Map para envio à API  
  Map<String, dynamic> buildItem() {
    if(validarNull() == false) {
      throw new ArgumentError.notNull("argumentos nulos");
    }
    Map<String, dynamic> item = {};
    item['id'] = getId()??0;
    item['result'] = getStatus();
    item['comments'] = comentario??'';
    item['photo'] = foto!.path;
    return item;
  }

  @override
  String toString() {
    return 'ItemCheckList{id: $id, descricao: $nome, status: $status}';
  }
}