import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sima_gestor_app/model/abastecimento.dart';
import 'package:sima_gestor_app/service/api_service.dart';
import 'package:sima_gestor_app/model/usuario.dart';
import 'package:sima_gestor_app/model/veiculo.dart';
import 'package:sima_gestor_app/service/abastecimento_service.dart';

class CadastroManualPage extends StatefulWidget {
  final Usuario usuario;

  const CadastroManualPage({Key? key, required this.usuario}) : super(key: key);

  @override
  State<CadastroManualPage> createState() => _CadastroManualPageState();
}

class _CadastroManualPageState extends State<CadastroManualPage> {
  List<Veiculo> _veiculos = [];
  String? _selectedPlaca;
  String? _selectedCombustivel;

  final TextEditingController placaController = TextEditingController();
  final TextEditingController kmController = TextEditingController();
  final TextEditingController combustivelController = TextEditingController();
  final TextEditingController valorPorLitroController = TextEditingController();
  final TextEditingController litrosAbastecidosController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController dataController = TextEditingController();
  DateTime? dataSelecionada;

  bool _isLoading = true;

  final List<String> _tiposCombustivel = [
    'Gasolina',
    'Etanol',
    'Diesel S10',
    'Diesel S500',
    'Gás Natural Veicular (GNV)',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    _loadPlacas(widget.usuario);

    valorPorLitroController.addListener(_calcularTotal);
    litrosAbastecidosController.addListener(_calcularTotal);
  }

  Future<void> mandarAbastecimento() async {
    setState(() => _isLoading = true);

    try {
      final combustivel = _selectedCombustivel == 'Outros' ? combustivelController.text.trim() : _selectedCombustivel ?? '';
      
      Abastecimento abastecimento = Abastecimento(
        placaController.text.trim(),
        dataSelecionada,
        double.tryParse(kmController.text.trim()),
        combustivel,
        double.tryParse(valorPorLitroController.text.replaceAll(',', '.')),
        double.tryParse(litrosAbastecidosController.text.replaceAll(',', '.')),
      );

      String resposta = await AbastecimentoService.enviarAbastecimento(
        widget.usuario.getServidor(),
        widget.usuario.getToken() ?? '',
        abastecimento,
      );

      dataController.clear();
      kmController.clear();
      combustivelController.clear();
      valorPorLitroController.clear();
      litrosAbastecidosController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resposta), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll(RegExp('Exception: '), '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadPlacas(Usuario user) async {
    setState(() => _isLoading = true);
    final api = APIService(user.getServidor(), user.getToken());

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

  Future<void> _selecionarDataHora() async {
    final now = DateTime.now();
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: dataSelecionada ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Colors.green),
        ),
        child: child!,
      ),
    );

    if (data != null) {
      final TimeOfDay? hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
        builder: (context, child) => Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: Colors.green),
          ),
          child: child!,
        ),
      );

      if (hora != null) {
        final selecionada = DateTime(
          data.year,
          data.month,
          data.day,
          hora.hour,
          hora.minute,
        );

        if (selecionada.isAfter(now)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Não é permitido escolher data futura."),
            ),
          );
          return;
        }

        setState(() {
          dataSelecionada = selecionada;
          dataController.text =
              "${selecionada.day.toString().padLeft(2, '0')}/"
              "${selecionada.month.toString().padLeft(2, '0')}/"
              "${selecionada.year} ${hora.hour.toString().padLeft(2, '0')}:"
              "${hora.minute.toString().padLeft(2, '0')}";
        });
      }
    }
  }

  ///  Formata estilo Pix (digita 500 => 5,00)
  String _formatarValorPix(String value) {
    String numeric = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeric.isEmpty) return '';
    while (numeric.length < 3) {
      numeric = '0$numeric';
    }
    double valor = double.parse(numeric) / 100.0;
    return valor.toStringAsFixed(2).replaceAll('.', ',');
  }

  ///  Campo genérico
  Widget _buildCampo(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
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
                  // 🔹 Dropdown de placa
                  DropdownButtonFormField<String>(
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
                    value: _selectedPlaca,
                    items: _veiculos.map((v) {
                      final placa = v.getPlaca()?.toString() ?? '(sem placa)';
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

                  const SizedBox(height: 16),

                  // 🔹 Data e hora
                  TextField(
                    controller: dataController,
                    style: const TextStyle(color: Colors.white),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Data e hora do checklist",
                      labelStyle: const TextStyle(color: Colors.white70),
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.green,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                    onTap: _selecionarDataHora,
                  ),

                  _buildCampo(
                    'KM',
                    kmController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  // 🔹 Dropdown de combustível
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Combustível',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                    dropdownColor: Colors.black,
                    value: _selectedCombustivel,
                    items: _tiposCombustivel.map((c) {
                      return DropdownMenuItem<String>(
                        value: c,
                        child: Text(
                          c,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCombustivel = val;
                        if (val != 'Outros') combustivelController.clear();
                      });
                    },
                  ),

                  // 🔹 Campo "Outros" aparece aqui
                  if (_selectedCombustivel == 'Outros')
                    _buildCampo('Informe o combustível', combustivelController),

                  // 🔹 Campos com formatação Pix
                  _buildCampo(
                    'Valor por Litro',
                    valorPorLitroController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final formatado = _formatarValorPix(value);
                      if (formatado != valorPorLitroController.text) {
                        valorPorLitroController.value = TextEditingValue(
                          text: formatado,
                          selection: TextSelection.collapsed(
                            offset: formatado.length,
                          ),
                        );
                      }
                    },
                  ),
                  _buildCampo(
                    'Litros Abastecidos',
                    litrosAbastecidosController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final formatado = _formatarValorPix(value);
                      if (formatado != litrosAbastecidosController.text) {
                        litrosAbastecidosController.value = TextEditingValue(
                          text: formatado,
                          selection: TextSelection.collapsed(
                            offset: formatado.length,
                          ),
                        );
                      }
                    },
                  ),

                  _buildCampo('Total (R\$)', totalController, readOnly: true),

                  const SizedBox(height: 25),

                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      onPressed: _isLoading ? null : mandarAbastecimento,
                      child: const Text(
                        'Salvar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
