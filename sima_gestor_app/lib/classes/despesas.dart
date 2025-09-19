class Despesa {
  int _id;
  DateTime _dataHora;
  String _tipoDespesa;
  double _valor;
  String _observacao;
  bool _recorrente;

  Despesa({
    required int id,
    required DateTime dataHora,
    required String tipoDespesa,
    required double valor,
    required String observacao,
    required bool recorrente,
  })  : _id = id,
        _dataHora = dataHora,
        _tipoDespesa = tipoDespesa,
        _valor = valor,
        _observacao = observacao,
        _recorrente = recorrente;

  int get id => _id;
  DateTime get dataHora => _dataHora;
  String get tipoDespesa => _tipoDespesa;
  double get valor => _valor;
  String get observacao => _observacao;
  bool get recorrente => _recorrente;

  set dataHora(DateTime novaData) => _dataHora = novaData;
  set tipoDespesa(String novoTipo) => _tipoDespesa = novoTipo;
  set valor(double novoValor) {
    if (novoValor >= 0) {
      _valor = novoValor;
    } else {
      throw ArgumentError("O valor da despesa não pode ser negativo.");
    }
  }

  set observacao(String novaObs) => _observacao = novaObs;
  set recorrente(bool novoRecorrente) => _recorrente = novoRecorrente;

  @override
  String toString() {
    return 'Despesa{id: $_id, dataHora: $_dataHora, tipo: $_tipoDespesa, '
        'valor: $_valor, obs: $_observacao, recorrente: $_recorrente}';
  }
}
