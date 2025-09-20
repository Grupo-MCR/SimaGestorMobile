class ItemCheckList {
  int id;
  String descricao;
  bool status;

  // Construtor
  ItemCheckList({
    required this.id,
    required this.descricao,
    required this.status,
  });

  // Método para alterar status
  void marcarStatus(bool novoStatus) {
    status = novoStatus;
    print("Item $id (${descricao}) marcado como ${status ? "concluído" : "pendente"}");
  }

  @override
  String toString() {
    return 'ItemCheckList{id: $id, descricao: $descricao, status: $status}';
  }
}