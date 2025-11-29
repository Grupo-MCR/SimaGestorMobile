import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sima_gestor_app/model/despesas.dart';
import 'package:sima_gestor_app/model/api_call.dart';
import 'package:sima_gestor_app/model/veiculo.dart';
import 'package:sima_gestor_app/service/despesa_service.dart';
import 'package:intl/intl.dart';

class InterfaceDespesas extends StatefulWidget {
  final String servidor;
  final String token;
  
  const InterfaceDespesas({
    Key? key, 
    required this.servidor, 
    required this.token
  }) : super(key: key);

  @override
  State<InterfaceDespesas> createState() => _InterfaceDespesasState();
}

class _InterfaceDespesasState extends State<InterfaceDespesas> {
  List<Veiculo> _veiculos = [];
  String? _selectedPlaca;
  
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _dataHoraController = TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();
  
  String? _tipoDespesaSelecionado;
  final List<String> _tiposDespesa = ['Pedágio', 'Combustível', 'Manutenção', 'Outros'];
  bool _recorrente = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tipoDespesaSelecionado = _tiposDespesa.first;
    _loadPlacas();
  }

  void _loadPlacas() async {
    setState(() => _isLoading = true);

    final api = APICall(widget.servidor, widget.token);

    try {
      var response = await api.receberVeiculos();

      setState(() {
        _veiculos = response;
        _isLoading = false;
      });
    } catch (e, stack) {
      print('Erro ao carregar placas: $e');
      print(stack);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cadastrarDespesa() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      if (_placaController.text.isEmpty) {
        throw Exception('Por favor, preencha a placa');
      }
      if (_valorController.text.isEmpty) {
        throw Exception('Por favor, preencha o valor');
      }
      if (_dataHoraController.text.isEmpty) {
        throw Exception('Por favor, preencha a data e hora');
      }

      double valor = double.parse(_valorController.text.replaceAll(',', '.'));
      
      // Validar se o valor é positivo
      if (valor <= 0) {
        throw Exception('O valor deve ser maior que zero');
      }

      DateTime dataHora = DateFormat('dd/MM/yyyy HH:mm').parse(_dataHoraController.text);

      Despesa despesa = Despesa(
        id: null,
        placa: _placaController.text.toUpperCase(),
        dataHora: dataHora,
        tipoDespesa: _tipoDespesaSelecionado ?? _tiposDespesa.first,
        valor: valor,
        observacao: _observacaoController.text,
        recorrente: _recorrente,
      );

      String resposta = await DespesaService.enviarDespesa(
        widget.servidor,
        widget.token,
        despesa,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resposta),
            backgroundColor: Colors.green,
          ),
        );

        _limparCampos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _limparCampos() {
    _selectedPlaca = null;
    _placaController.clear();
    _valorController.clear();
    _dataHoraController.clear();
    _observacaoController.clear();
    setState(() {
      _tipoDespesaSelecionado = _tiposDespesa.first;
      _recorrente = false;
    });
  }

  void _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              titleMedium: TextStyle(color: Colors.white),
              headlineMedium: TextStyle(color: Colors.white),
              headlineSmall: TextStyle(color: Colors.white),
              labelLarge: TextStyle(color: Colors.white),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.white70),
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.green,
                onPrimary: Colors.white,
                surface: Colors.black,
                onSurface: Colors.white,
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white),
                titleMedium: TextStyle(color: Colors.white),
                headlineMedium: TextStyle(color: Colors.white),
                headlineSmall: TextStyle(color: Colors.white),
                labelLarge: TextStyle(color: Colors.white),
              ),
              dialogBackgroundColor: Colors.black,
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          // Formato brasileiro: dd/MM/yyyy HH:mm
          _dataHoraController.text =
              "${combined.day.toString().padLeft(2, '0')}/${combined.month.toString().padLeft(2, '0')}/${combined.year} "
              "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Cadastro de Despesa',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  /// Dropdown de Placas
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Placa',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                      dropdownColor: Colors.black,
                      value:
                          _selectedPlaca != null &&
                              _veiculos.any(
                                (v) => v.getPlaca() == _selectedPlaca,
                              )
                          ? _selectedPlaca
                          : null,
                      items: _veiculos.map((v) {
                        final placa =
                            v.getPlaca()?.toString() ?? '(sem placa)';
                        return DropdownMenuItem<String>(
                          value: placa,
                          child: Text(
                            placa,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedPlaca = val;
                          _placaController.text = val ?? '';
                        });
                      },
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: _dataHoraController,
                      readOnly: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Data e Hora',
                        labelStyle: TextStyle(color: Colors.white70),
                        hintText: 'DD/MM/AAAA HH:MM',
                        hintStyle: TextStyle(color: Colors.white30),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.green,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                      onTap: () => _selectDateTime(context),
                    ),
                  ),

                  // Campo de valor com validação para apenas números positivos
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: _valorController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Valor (R\$)',
                        labelStyle: TextStyle(color: Colors.white),
                        hintText: '0.00',
                        hintStyle: TextStyle(color: Colors.white30),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                  ),
                  
                  _buildCampo('Observação', _observacaoController),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Despesa',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                      dropdownColor: Colors.black,
                      value: _tipoDespesaSelecionado,
                      items: _tiposDespesa.map((tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(
                            tipo,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _tipoDespesaSelecionado = val;
                        });
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _recorrente,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _recorrente = newValue ?? false;
                            });
                          },
                          activeColor: Colors.green,
                          checkColor: Colors.white,
                        ),
                        const Text(
                          'Recorrente?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                        onPressed: _isLoading ? null : _cadastrarDespesa,
                        child: const Text(
                          'Salvar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCampo(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _placaController.dispose();
    _valorController.dispose();
    _dataHoraController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }
}