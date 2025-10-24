import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:sima_gestor_app/model/api_call.dart';
import 'package:sima_gestor_app/model/item_checklist.dart';
import 'package:sima_gestor_app/model/usuario.dart';
import 'package:sima_gestor_app/model/veiculo.dart';
import 'package:sima_gestor_app/service/checklist_service.dart';

class CheckListPage extends StatefulWidget {
  final Usuario usuario;

  const CheckListPage({Key? key, required this.usuario}) : super(key: key);

  @override
  State<CheckListPage> createState() => _CheckListPageState();
}

class _CheckListPageState extends State<CheckListPage> {
  final ImagePicker _picker = ImagePicker();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.white,
  );

  final TextEditingController _responsavelController = TextEditingController();

  List<Veiculo> _veiculos = [];
  List<Usuario> _motoristas = [];
  String? _selectedPlaca;
  String? _selectedMotorista;
  bool _isLoading = true;

  List<ItemCheckList> _itens = [];

  @override
  void initState() {
    super.initState();
    _loadPlacas(widget.usuario);
  }

  void _loadItens(Usuario user, Veiculo veiculo) async {
    setState(() => _isLoading = true);

    final api = APICall(user.getServidor(), user.getToken());

    try {
      var response = await api.receberItensChecklist(veiculo.getId() ?? 1);
      setState(() {
        _itens = response;
        _isLoading = false;
      });
    } catch (e, stack) {
      print('Erro ao carregar itens: $e');
      print(stack);
      setState(() => _isLoading = false);
    }
  }

  void _loadPlacas(Usuario user) async {
    setState(() => _isLoading = true);

    final api = APICall(user.getServidor(), user.getToken());

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

  Future<void> _loadMotoristas(Usuario user) async {
    setState(() {
      _isLoading = true;
      _motoristas = [];
      _selectedMotorista = null;
    });

    final api = APICall(user.getServidor(), user.getToken());

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      var response = await api.receberMotoristas();

      setState(() {
        _motoristas = response;
        _isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar motoristas: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selecionarImagem(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final item = _itens[index];

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          item.setFotoBytes(bytes);
          item.setFoto(null);
          _itens[index] = item;
        });
      } else {
        setState(() {
          item.setFoto(File(image.path));
          item.setFotoBytes(null);
          _itens[index] = item;
        });
      }
    }
  }

  void _salvarChecklist() async {
    if (_selectedPlaca == null || _selectedMotorista == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione a placa e o motorista.")),
      );
      return;
    }

    if (_responsavelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Insira o nome do responsável.")),
      );
      return;
    }

    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Adicione a assinatura digital.")),
      );
      return;
    }

    final assinaturaBytes = await _signatureController.toPngBytes();
    final assinaturaBase64 = base64Encode(assinaturaBytes!);

    final api = APICall(widget.usuario.getServidor(), widget.usuario.getToken());
    final service = ChecklistService(api);

    final veiculo = _veiculos.firstWhere((v) => v.getPlaca() == _selectedPlaca);
    final motorista = _motoristas.firstWhere((m) => m.getNome() == _selectedMotorista);

    final sucesso = await service.processarChecklist(
      idVeiculo: veiculo.getId()!,
      idMotorista: motorista.getId()!,
      nomeVerificador: _responsavelController.text.trim(),
      assinaturaBase64: assinaturaBase64,
      itens: _itens,
    );

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Checklist enviado com sucesso!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao enviar checklist.")),
      );
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _responsavelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Checklist do Veículo",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Placa do veículo',
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
                      if (val != null) {
                        setState(() {
                          _selectedPlaca = val;
                          _motoristas = [];
                          _selectedMotorista = null;
                        });
                        _loadMotoristas(widget.usuario);
                        _loadItens(
                          widget.usuario,
                          _veiculos.firstWhere(
                            (veiculo) => veiculo.getPlaca() == _selectedPlaca,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Motorista',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                    dropdownColor: Colors.black,
                    value: _selectedMotorista,
                    items: _motoristas
                        .map(
                          (m) => DropdownMenuItem<String>(
                            value: m.getNome(),
                            child: Text(
                              m.getNome() ?? 'unamed',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedMotorista = val);
                    },
                  ),
                  const Divider(color: Colors.white38, height: 40),
                  if (_selectedPlaca != null && _selectedMotorista != null)
                    ..._buildChecklist(),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildChecklist() {
    return [
      ..._itens.asMap().entries.map((entry) {
        int index = entry.key;
        var item = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.getNome() ?? 'unamed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.getStatus() == true
                            ? Colors.green
                            : Colors.grey[800],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          item.setStatus(true);
                          item.setComentario("");
                        });
                      },
                      child: const Text("OK"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.getStatus() == false
                            ? Colors.red
                            : Colors.grey[800],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          item.setStatus(false);
                        });
                      },
                      child: const Text("Não OK"),
                    ),
                  ),
                ],
              ),
              if (item.getStatus() == false) ...[
                const SizedBox(height: 10),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Descreva o problema",
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    item.setComentario(value);
                  },
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo, color: Colors.white),
                    label: const Text(
                      "Anexar foto da galeria",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _selecionarImagem(index),
                  ),
                ),
                if (item.getFoto() != null || item.getFotoBytes() != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.memory(
                            item.getFotoBytes()!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            item.getFoto()!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ],
              ],
            ],
          ),
        );
      }),
      const Divider(color: Colors.white38, height: 40),
      const Text(
        "Responsável pelo checklist:",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _responsavelController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Digite o nome completo",
          hintStyle: const TextStyle(color: Colors.white54),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.green),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        "Assinatura digital:",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[900],
        ),
        height: 150,
        child: Signature(
          controller: _signatureController,
          backgroundColor: Colors.grey[900]!,
        ),
      ),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => _signatureController.clear(),
          child: const Text(
            "Limpar assinatura",
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
      const SizedBox(height: 30),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            foregroundColor: Colors.white,
          ),
          onPressed: _salvarChecklist,
          child: const Text(
            "Salvar Checklist",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ];
  }
}
