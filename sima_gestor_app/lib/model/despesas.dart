class Despesa {
  int? _id;
  String _placa;
  DateTime _dataHora;
  String _tipoDespesa;
  double _valor;
  String _observacao;
  bool _recorrente;

  Despesa({
    required int? id,
    required String placa,
    required DateTime dataHora,
    required String tipoDespesa,
    required double valor,
    required String observacao,
    required bool recorrente,
  }) : _id = id,
       _placa = placa,
       _dataHora = dataHora,
       _tipoDespesa = tipoDespesa,
       _valor = valor,
       _observacao = observacao,
       _recorrente = recorrente;

  int? get id => _id;
  String get dataHora =>
      _dataHora
          .toIso8601String()
          .substring(0, 17)
          .replaceAll(RegExp(r'T'), ' ') +
      (_dataHora.second.toString().length < 2
          ? '0' + _dataHora.second.toString()
          : _dataHora.second.toString());
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

  bool validarNull() {
    return _placa.isNotEmpty && _tipoDespesa.isNotEmpty && _valor > 0;
  }

  Map<String, dynamic> buildDespesa() {
    Map<String, dynamic> despesa = {};
    despesa["placa"] = _placa;
    despesa["data_hora"] = dataHora;
    despesa["tipo_despesa"] = _tipoDespesa;
    despesa["valor"] = _valor;
    despesa["observacao"] = _observacao;
    despesa["recorrente"] = _recorrente ? 1 : 0;
    return despesa;
  }

  @override
  String toString() {
    return 'Despesa{id: $_id, placa: $_placa, dataHora: $dataHora, tipo: $_tipoDespesa, '
        'valor: $_valor, obs: $_observacao, recorrente: $_recorrente}';
  }
}