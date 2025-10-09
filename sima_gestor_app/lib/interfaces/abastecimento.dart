import 'package:flutter/material.dart';
import 'package:sima_gestor_app/classes/api_call.dart';
import 'package:sima_gestor_app/classes/usuario.dart';

class CadastroManualPage extends StatefulWidget {
  final Usuario usuario;

  const CadastroManualPage({Key? key, required this.usuario}) : super(key: key);

  @override
  State<CadastroManualPage> createState() => _CadastroManualPageState();
}

class _CadastroManualPageState extends State<CadastroManualPage> {
  List<Map<String, dynamic>> _veiculos = [];
  String? _selectedPlaca;

  final TextEditingController placaController = TextEditingController();
  final TextEditingController dataHoraController = TextEditingController();
  final TextEditingController kmController = TextEditingController();
  final TextEditingController combustivelController = TextEditingController();
  final TextEditingController valorPorLitroController = TextEditingController();
  final TextEditingController litrosAbastecidosController =
      TextEditingController();
  final TextEditingController totalController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlacas(widget.usuario);
    valorPorLitroController.addListener(_calcularTotal);
    litrosAbastecidosController.addListener(_calcularTotal);
  }

  /// 🔹 Carrega as placas de veículos pela API
  void _loadPlacas(Usuario user) async {
    setState(() => _isLoading = true);

    final api = APICall(user.getServidor(), user.getToken());

    try {
      var response = await api.receberVeiculos();
      print("DEBUG >> retorno da API: $response");

      List<Map<String, dynamic>> veiculosList = [];

      // Trata o formato da resposta da API
      if (response is List) {
        veiculosList = List<Map<String, dynamic>>.from(response);
      } else if (response is Map && response['data'] is List) {
        veiculosList = List<Map<String, dynamic>>.from(response['data']);
      } else {
        print("Formato inesperado de resposta de veículos.");
      }

      setState(() {
        _veiculos = veiculosList;
        _isLoading = false;
      });
    } catch (e, stack) {
      print('Erro ao carregar placas: $e');
      print(stack);
      setState(() => _isLoading = false);
    }
  }

  /// 🔹 Atualiza o total automaticamente
  void _calcularTotal() {
    final double valorPorLitro =
        double.tryParse(valorPorLitroController.text.replaceAll(',', '.')) ?? 0;
    final double litros =
        double.tryParse(
          litrosAbastecidosController.text.replaceAll(',', '.'),
        ) ??
        0;
    final double total = valorPorLitro * litros;

    totalController.text = total.toStringAsFixed(2);
  }

  /// 🔹 Abre o seletor de data + hora
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
          dataHoraController.text =
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
          'Cadastro Manual',
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
                  /// 🔹 Dropdown de Placas
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
                              _veiculos.any((v) => v['placa'] == _selectedPlaca)
                          ? _selectedPlaca
                          : null,
                      items: _veiculos.map((v) {
                        final placa =
                            v['placa']?.toString() ??
                            v['Placa']?.toString() ??
                            v['veiculoPlaca']?.toString() ??
                            '(sem placa)';
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
                          placaController.text = val ?? '';
                        });
                      },
                    ),
                  ),

                  /// 🔹 Campo Data + Hora
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: dataHoraController,
                      readOnly: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Data e Hora',
                        labelStyle: TextStyle(color: Colors.white70),
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

                  _buildCampo('KM', kmController),
                  _buildCampo('Combustível', combustivelController),
                  _buildCampo(
                    'Valor por Litro',
                    valorPorLitroController,
                    keyboardType: TextInputType.number,
                  ),
                  _buildCampo(
                    'Litros Abastecidos',
                    litrosAbastecidosController,
                    keyboardType: TextInputType.number,
                  ),
                  _buildCampo('Total (R\$)', totalController, readOnly: true),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Dados salvos com sucesso!'),
                            ),
                          );
                        },
                        child: const Text(
                          'Salvar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Voltar',
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

  /// 🔹 Campo de texto genérico
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
}
