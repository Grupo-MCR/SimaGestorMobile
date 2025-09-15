class Veiculo {
  int? id;
  String? placa;
  String? tipo;

  Veiculo(this.id, this.placa, this.tipo);

  bool validarNull() {
    if(id == null || placa == null || tipo == null) {
      return false;
    }
    return true;
  }

  bool validarPlaca() {
    String tsplaca = placa??'';
    if(tsplaca.length == 7) {
      placa = tsplaca.toUpperCase();
      return true;
    }
    return false;
  }

  void setId(int id) {
    this.id = id;
  }

  int? getId() {
    return id;
  }

  void setPlaca(String placa) {
    this.placa = placa.toUpperCase();
    return;
  }

  String? getPlaca() {
    return placa;
  }

  void setTipo(String tipo) {
    this.tipo = tipo;
  }

  String? getTipo() {
    return tipo;
  }

  @override
  String toString() {
    return "veiculo = {id: $id; placa: $placa; tipo: $tipo}";
  }
}