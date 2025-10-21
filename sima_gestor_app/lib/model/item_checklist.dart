import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class ItemCheckList {
  int? id;
  String? nome;
  String? comentario;
  File? foto;
  Uint8List? fotoBytes; // usado para web
  bool? status; // true = OK, false = Não OK, null = não respondido

  // 🔹 Construtor
  ItemCheckList({this.id, this.nome, this.status});

  // 🔹 Criação a partir de JSON recebido da API
  factory ItemCheckList.fromJson(Map<String, dynamic> json) {
    return ItemCheckList(
      id: json['id'] as int?,
      nome: json['item_name'] as String?,
      status: null, // começa nulo até o usuário responder
    );
  }

  // ===============================
  // 🔹 GETTERS / SETTERS
  // ===============================

  int? getId() => id;
  void setId(int id) => this.id = id;

  String? getNome() => nome;
  void setNome(String nome) => this.nome = nome;

  String? getComentario() => comentario;
  void setComentario(String comentario) => this.comentario = comentario;

  File? getFoto() => foto;
  void setFoto(File? foto) => this.foto = foto;

  Uint8List? getFotoBytes() => fotoBytes;
  void setFotoBytes(Uint8List? bytes) => fotoBytes = bytes;

  bool? getStatus() => status;
  void setStatus(bool? valor) => status = valor;

  // ===============================
  // 🔹 FUNÇÕES AUXILIARES
  // ===============================

  /// Retorna o status em formato de string para API
  String getStatusString() {
    if (status == null) return "nao_respondeu";
    return status! ? "ok" : "not_ok";
  }

  /// Verifica se o item tem dados válidos antes do envio
  bool validarNull() {
    if (id == null || nome == null) return false;

    // Se o status for "não OK", precisa de comentário e foto
    if (status == false &&
        (comentario == null || (foto == null && fotoBytes == null))) {
      return false;
    }

    return true;
  }

  /// 🔹 Alterna o status entre true / false / null
  /// null → true → false → true ...
  void alterarStatus() {
    if (status == null) {
      status = true;
    } else {
      status = !status!;
    }
  }

  /// 🔹 Gera o mapa para envio à API
  Map<String, dynamic> buildItem() {
    if (!validarNull()) {
      throw ArgumentError.notNull("argumentos nulos");
    }

    final Map<String, dynamic> item = {};
    item['id'] = getId() ?? 0;
    item['result'] = getStatusString();
    item['comments'] = comentario ?? '';

    // Envia foto apenas se status não for OK
    if (getStatusString() != "ok") {
      if (kIsWeb && fotoBytes != null) {
        item['photo'] = fotoBytes;
      } else {
        item['photo'] = foto?.path ?? '';
      }
    }

    return item;
  }

  @override
  String toString() {
    return 'ItemCheckList{id: $id, nome: $nome, status: $status, fotoFile: ${foto == null ? 'false' : 'true'}, fotoBytes: ${fotoBytes == null ? 'false' : 'true'}}';
  }
}
