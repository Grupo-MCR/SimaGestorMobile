import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
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
  String get restorationScopeId => 'ChecklistPage';

  @override
  State<CheckListPage> createState() => _CheckListPageState();
}

class _CheckListPageState extends State<CheckListPage> 
    with RestorationMixin, WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.white,
  );

  final RestorableTextEditingController _responsavelController = 
      RestorableTextEditingController();
  
  // Adicionar Restorables para manter estado
  final RestorableString _selectedPlacaRestoration = RestorableString('');
  final RestorableString _selectedMotoristaRestoration = RestorableString('');
  final RestorableBool _isLoadingRestoration = RestorableBool(true);

  List<Veiculo> _veiculos = [];
  List<Usuario> _motoristas = [];
  String? _selectedPlaca;
  String? _selectedMotorista;
  bool _isLoading = true;

  List<ItemCheckList> _itens = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPlacas(widget.usuario);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _signatureController.dispose();
    _responsavelController.dispose();
    _selectedPlacaRestoration.dispose();
    _selectedMotoristaRestoration.dispose();
    _isLoadingRestoration.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Monitora quando o app volta do background
    if (state == AppLifecycleState.resumed) {
      print('App retornou do background');
      // Força rebuild para manter a tela
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  String? get restorationId => 'ChecklistPageRestoration';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_responsavelController, 'responsavel');
    registerForRestoration(_selectedPlacaRestoration, 'selectedPlaca');
    registerForRestoration(_selectedMotoristaRestoration, 'selectedMotorista');
    registerForRestoration(_isLoadingRestoration, 'isLoading');
    
    // Restaurar valores
    if (_selectedPlacaRestoration.value.isNotEmpty) {
      _selectedPlaca = _selectedPlacaRestoration.value;
    }
    if (_selectedMotoristaRestoration.value.isNotEmpty) {
      _selectedMotorista = _selectedMotoristaRestoration.value;
    }
    _isLoading = _isLoadingRestoration.value;
  }

  String cameraStatus = 'desconhecido';

  Future<void> _checkCamera() async {
    final status = await Permission.camera.status;
    setState(() => cameraStatus = status.toString());
  }

  Future<void> _requestCamera() async {
    final status = await Permission.camera.request();
    setState(() => cameraStatus = status.toString());
  }

  void _loadItens(Usuario user, Veiculo veiculo) async {
    setState(() => _isLoading = true);
    _isLoadingRestoration.value = true;

    final api = APICall(user.getServidor(), user.getToken());

    try {
      var response = await api.receberItensChecklist(veiculo.getId() ?? 1);
      if (mounted) {
        setState(() {
          _itens = response;
          _isLoading = false;
          _isLoadingRestoration.value = false;
        });
      }
    } catch (e, stack) {
      print('Erro ao carregar itens: $e');
      print(stack);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingRestoration.value = false;
        });
      }
    }
  }

  void _loadPlacas(Usuario user) async {
    setState(() => _isLoading = true);
    _isLoadingRestoration.value = true;

    final api = APICall(user.getServidor(), user.getToken());

    try {
      var response = await api.receberVeiculos();
      if (mounted) {
        setState(() {
          _veiculos = response;
          _isLoading = false;
          _isLoadingRestoration.value = false;
        });
      }
    } catch (e, stack) {
      print('Erro ao carregar placas: $e');
      print(stack);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingRestoration.value = false;
        });
      }
    }
  }

  Future<void> _loadMotoristas(Usuario user) async {
    setState(() {
      _isLoading = true;
      _motoristas = [];
      _selectedMotorista = null;
    });
    _isLoadingRestoration.value = true;

    final api = APICall(user.getServidor(), user.getToken());

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      var response = await api.receberMotoristas();

      if (mounted) {
        setState(() {
          _motoristas = response;
          _isLoading = false;
          _isLoadingRestoration.value = false;
        });
      }
    } catch (e) {
      print("Erro ao carregar motoristas: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingRestoration.value = false;
        });
      }
    }
  }

  Future<void> _selecionarImagem(int index) async {
    try {
      await _requestCamera();
      await _checkCamera();
      
      XFile? image;
      if (kIsWeb) {
        image = await _picker.pickImage(source: ImageSource.gallery);
      } else {
        image = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
          preferredCameraDevice: CameraDevice.rear,
        );
      }

      if (image != null && mounted) {
        final item = _itens[index];
        
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            item.setFotoBytes(bytes);
            item.setFoto(null);
            _itens[index] = item;
          });
        } else {
          final imagePath = image.path;
          if (imagePath.isNotEmpty) {
            setState(() {
              item.setFoto(File(imagePath));
              item.setFotoBytes(null);
              _itens[index] = item;
            });
          }
        }
        
        print('Foto capturada com sucesso para o item $index');
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao capturar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _salvarChecklist() async {
    // Validações principais
    if (_selectedPlaca == null || _selectedMotorista == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecione a placa e o motorista.",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_responsavelController.value.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Insira o nome do responsável.",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Adicione a assinatura digital.",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validação dos itens do checklist
    for (final item in _itens) {
      if (item.getStatus() == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Responda o item '${item.getNome() ?? "sem nome"}'.",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (item.getStatus() == false) {
        if (item.getComentario() == null || item.getComentario()!.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Adicione um comentário no item '${item.getNome() ?? "sem nome"}'.",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (item.getFoto() == null && item.getFotoBytes() == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Adicione uma foto para o item '${item.getNome() ?? "sem nome"}'.",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    // Se tudo estiver válido, prossegue com o envio
    final assinaturaBytes = await _signatureController.toPngBytes();
    final assinaturaBase64 = base64Encode(assinaturaBytes!);

    final api = APICall(widget.usuario.getServidor(), widget.usuario.getToken());
    final service = ChecklistService(api);

    final veiculo = _veiculos.firstWhere((v) => v.getPlaca() == _selectedPlaca);
    final motorista = _motoristas.firstWhere((m) => m.getNome() == _selectedMotorista);

    final sucesso = await service.processarChecklist(
      idVeiculo: veiculo.getId()!,
      idMotorista: motorista.getId()!,
      nomeVerificador: _responsavelController.value.text.trim(),
      assinaturaBase64: assinaturaBase64,
      itens: _itens,
    );

    if (mounted) {
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Checklist enviado com sucesso!",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao enviar checklist.",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                          _selectedPlacaRestoration.value = val;
                          _motoristas = [];
                          _selectedMotorista = null;
                          _selectedMotoristaRestoration.value = '';
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
                      setState(() {
                        _selectedMotorista = val;
                        _selectedMotoristaRestoration.value = val ?? '';
                      });
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
                    icon: const Icon(Icons.camera, color: Colors.white),
                    label: const Text(
                      "Abrir a câmera",
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
        controller: _responsavelController.value,
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