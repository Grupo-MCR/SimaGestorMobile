class Despesas {
  int id;
  DateTime dataHora;
  String tipoDespesa;
  double valor;
  String observacao;
  bool recorrente;

  // Construtor
  Despesas({
    required this.id,
    required this.dataHora,
    required this.tipoDespesa,
    required this.valor,
    required this.observacao,
    required this.recorrente,
  });

  // Métodos
  void buscarDespesas() {
    print("Buscando despesas...");
  }

  void editarDespesas({
    DateTime? novaDataHora,
    String? novoTipo,
    double? novoValor,
    String? novaObs,
    bool? novoRecorrente,
  }) {
    if (novaDataHora != null) dataHora = novaDataHora;
    if (novoTipo != null) tipoDespesa = novoTipo;
    if (novoValor != null) valor = novoValor;
    if (novaObs != null) observacao = novaObs;
    if (novoRecorrente != null) recorrente = novoRecorrente;

    print("Despesa $id editada com sucesso!");
  }

  void excluirDespesa() {
    print("Despesa $id excluída!");
  }

  @override
  String toString() {
    return 'Despesa{id: $id, dataHora: $dataHora, tipo: $tipoDespesa, '
           'valor: $valor, obs: $observacao, recorrente: $recorrente}';
  }
}
