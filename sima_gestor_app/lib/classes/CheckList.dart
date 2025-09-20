class CheckList {
  int id;
  DateTime checkListDate;
  List<ItemCheckList> itemVerificados;

  // Construtor
  CheckList({
    required this.id,
    required this.checkListDate,
    required this.itemVerificados,
  });

  // Método para buscar os dados (simulação)
  void buscarDados() {
    print("Buscando dados do checklist $id...");
  }

  @override
  String toString() {
    return 'CheckList{id: $id, data: $checkListDate, itens: $itemVerificados}';
  }
}