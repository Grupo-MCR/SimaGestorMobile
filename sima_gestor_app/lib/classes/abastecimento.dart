class Abastecimento {
  int? id;
  String? placa;
  DateTime? dataHora;
  double? km;
  String? combustivel;
  double? valorLitro;
  double? litrosAbastecidos;
  double? totalReais;

  Abastecimento(String? placa,
                  DateTime? dataHora,
                  double? km,
                  String? combustivel,
                  double? valorLitro,
                  double? litrosAbastecidos) {
    this.placa = placa;
    this.dataHora = dataHora;
    this.km = km;
    this.combustivel = combustivel;
    this.valorLitro = valorLitro;
    this.litrosAbastecidos = litrosAbastecidos;
    calcularValorTotal();
  }

  bool validarNull() {
    if(dataHora == null ||
        km == null ||
        combustivel == null ||
        valorLitro == null ||
        litrosAbastecidos == null ||
        totalReais == null) {
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

  String? getPlaca() {
    return placa;
  }

  void setPlaca(String placa) {
    this.placa = placa;
  }

  String? getDataHora() {
    DateTime dataHoraAtual = dataHora??DateTime.now();
    return dataHoraAtual.toIso8601String().substring(0, 17).replaceAll(RegExp(r'T'), ' ')+(dataHoraAtual.second.toString().length<2?'0'+dataHoraAtual.second.toString():dataHoraAtual.second.toString());
  }

  void setDataHora(DateTime dataHora) {
    this.dataHora = dataHora;
  }

  double? getKm() {
    return km;
  }

  void setKm(double km) {
    this.km = km;
  }

  String? getTipoCombustivel() {
    return combustivel;
  }

  void setTipoCombustivel(String tipoCombustivel) {
    this.combustivel = tipoCombustivel;
  }

  double? getValorLitro() {
    return valorLitro;
  }

  void setValorLitro(double valorLitro) {
    this.valorLitro = valorLitro;
    calcularValorTotal();
  }

  double? getLitrosAbastecidos() {
    return litrosAbastecidos;
  }

  void setLitrosAbastecidos(double litrosAbastecidos) {
    this.litrosAbastecidos = litrosAbastecidos;
    calcularValorTotal();
  }

  double? getValorTotal() {
    return totalReais;
  }

  void calcularValorTotal() {
    if(valorLitro == null || litrosAbastecidos == null) {
      throw new ArgumentError.notNull("erro: o preço do litro e/ou a quantidade abastecida não foram informadas");
    }
    this.totalReais =  (valorLitro??1) * (litrosAbastecidos??1);
  }

  Map<String, dynamic> buildAbastecimento() {
    if(validarNull() == false) {
      throw new ArgumentError.notNull("erro: informações incorretas");
    }
    Map<String, dynamic> abastecimento = {};
    abastecimento["placa"] = placa;
    abastecimento["data_hora"] = getDataHora();
    abastecimento["km"] = km;
    abastecimento["combustivel"] = combustivel;
    abastecimento["valor_por_litro"] = valorLitro;
    abastecimento["litros_abastecidos"] = litrosAbastecidos;
    abastecimento["total_reais"] = totalReais;
    return abastecimento;
  }

  @override
  String toString() {
    return "abastecimento = {id: $id, placa: $placa, dataHora: ${getDataHora()}, km: $km, combustivel: $combustivel, valorLitro: $valorLitro, litrosAbastecidos: $litrosAbastecidos, totalReais: $totalReais};";
  }
}