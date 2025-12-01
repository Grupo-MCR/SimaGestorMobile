import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sima_gestor_app/service/api_service.dart';
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

class _CheckListPageState extends State<CheckListPage> 
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  
  @override
  bool get wantKeepAlive => true;

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
  int? _pendingPhotoIndex; // Índice do item aguardando foto

  List<ItemCheckList> _itens = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeState();
  }

  Future<void> _initializeState() async {
    // Tenta restaurar estado salvo
    final restored = await _restoreState();
    
    if (!restored) {
      // Se não há estado salvo, carrega normalmente
      _loadPlacas(widget.usuario);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _signatureController.dispose();
    _responsavelController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    
    if (state == AppLifecycleState.paused) {
      _saveState();
    } else if (state == AppLifecycleState.resumed) {
      _restoreStateOnResume();
    }
  }

  // Salva o estado atual
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('checklist_placa', _selectedPlaca ?? '');
      await prefs.setString('checklist_motorista', _selectedMotorista ?? '');
      await prefs.setString('checklist_responsavel', _responsavelController.text);
      await prefs.setInt('checklist_pending_photo', _pendingPhotoIndex ?? -1);
      
      // Salva os dados dos itens do checklist
      List<Map<String, dynamic>> itensData = [];
      for (int i = 0; i < _itens.length; i++) {
        final item = _itens[i];
        itensData.add({
          'index': i,
          'status': item.getStatus(),
          'comentario': item.getComentario() ?? '',
          'fotoPath': item.getFoto()?.path ?? '',
        });
      }
      await prefs.setString('checklist_itens', jsonEncode(itensData));

    } catch (e) {
      print('Erro ao salvar estado: $e');
    }
  }

  // Restaura o estado após resumir
  Future<void> _restoreStateOnResume() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final restored = await _restoreState();
    
    if (restored && mounted) {
      setState(() {});
    }
  }

  // Restaura o estado salvo
  Future<bool> _restoreState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final savedPlaca = prefs.getString('checklist_placa');
      final savedMotorista = prefs.getString('checklist_motorista');
      final savedResponsavel = prefs.getString('checklist_responsavel');
      final savedPendingPhoto = prefs.getInt('checklist_pending_photo');
      final savedItensJson = prefs.getString('checklist_itens');
      
      // Verifica se há uma foto pendente de processamento
      final lastPhotoPath = prefs.getString('checklist_last_photo_path');
      final lastPhotoIndex = prefs.getInt('checklist_last_photo_index');
      
      if (savedPlaca == null || savedPlaca.isEmpty) {
        return false;
      }
      
      // Carrega os dados necessários
      setState(() => _isLoading = true);
      
      await _loadPlacas(widget.usuario);
      
      if (_veiculos.isNotEmpty) {
        _selectedPlaca = savedPlaca;
        
        await _loadMotoristas(widget.usuario);
        
        if (savedMotorista != null && savedMotorista.isNotEmpty) {
          _selectedMotorista = savedMotorista;
        }
        
        final veiculo = _veiculos.firstWhere(
          (v) => v.getPlaca() == savedPlaca,
          orElse: () => _veiculos.first,
        );
        
        await _loadItens(widget.usuario, veiculo);
        
        // Restaura os dados dos itens
        if (savedItensJson != null && savedItensJson.isNotEmpty) {
          try {
            final List<dynamic> itensData = jsonDecode(savedItensJson);
            
            for (var itemData in itensData) {
              final index = itemData['index'] as int;
              if (index >= 0 && index < _itens.length) {
                final item = _itens[index];
                
                // Restaura status
                final status = itemData['status'];
                if (status != null) {
                  item.setStatus(status as bool);
                }
                
                // Restaura comentário
                final comentario = itemData['comentario'] as String?;
                if (comentario != null && comentario.isNotEmpty) {
                  item.setComentario(comentario);
                }
                
                // Restaura foto
                final fotoPath = itemData['fotoPath'] as String?;
                if (fotoPath != null && fotoPath.isNotEmpty) {
                  final file = File(fotoPath);
                  if (await file.exists()) {
                    item.setFoto(file);
                    item.setFotoBytes(null);
                  }
                }
              }
            }
          } catch (e) {
          }
        }
        
        // Processa foto pendente se existir
        if (lastPhotoPath != null && lastPhotoIndex != null && 
            lastPhotoIndex >= 0 && lastPhotoIndex < _itens.length) {
          final file = File(lastPhotoPath);
          if (await file.exists()) {
            final item = _itens[lastPhotoIndex];
            item.setFoto(file);
            item.setFotoBytes(null);
            
            // Limpa os dados da foto pendente
            await prefs.remove('checklist_last_photo_path');
            await prefs.remove('checklist_last_photo_index');
            
            // Salva o estado atualizado
            await _saveState();
          } else {
          }
        }
        
        _responsavelController.text = savedResponsavel ?? '';
        _pendingPhotoIndex = (savedPendingPhoto != null && savedPendingPhoto >= 0) 
            ? savedPendingPhoto 
            : null;
      }
      
      setState(() => _isLoading = false);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Limpa o estado salvo
  Future<void> _clearSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('checklist_placa');
      await prefs.remove('checklist_motorista');
      await prefs.remove('checklist_responsavel');
      await prefs.remove('checklist_pending_photo');
      await prefs.remove('checklist_itens');
      await prefs.remove('checklist_last_photo_path');
      await prefs.remove('checklist_last_photo_index');
    } catch (e) {

    }
  }

  String cameraStatus = 'desconhecido';

  Future<void> _checkCamera() async {
    final status = await Permission.camera.status;
    if (mounted) {
      setState(() => cameraStatus = status.toString());
    }
  }

  Future<void> _requestCamera() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() => cameraStatus = status.toString());
    }
  }

  Future<void> _loadItens(Usuario user, Veiculo veiculo) async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    final api = APIService(user.getServidor(), user.getToken());

    try {
      var response = await api.receberItensChecklist(veiculo.getId() ?? 1);
      if (mounted) {
        setState(() {
          _itens = response;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      print(stack);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadPlacas(Usuario user) async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    final api = APIService(user.getServidor(), user.getToken());

    try {
      var response = await api.receberVeiculos();
      if (mounted) {
        setState(() {
          _veiculos = response;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      print(stack);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMotoristas(Usuario user) async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      if (_motoristas.isEmpty) {
        _selectedMotorista = null;
      }
    });

    final api = APIService(user.getServidor(), user.getToken());

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      var response = await api.receberMotoristas();

      if (mounted) {
        setState(() {
          _motoristas = response;
          _isLoading = false;
        });
        print('Motoristas carregados: ${_motoristas.length}');
      }
    } catch (e) {
      print("Erro ao carregar motoristas: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selecionarImagem(int index) async {
    
    // Salva qual item está aguardando foto
    _pendingPhotoIndex = index;
    await _saveState();
    
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

      if (image == null) {
        _pendingPhotoIndex = null;
        await _saveState();
        return;
      }

      // SALVA O PATH DA FOTO IMEDIATAMENTE, antes de verificar se está montado
      final imagePath = image.path;
      
      if (imagePath.isNotEmpty) {
        // Salva o path no SharedPreferences IMEDIATAMENTE
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('checklist_last_photo_path', imagePath);
        await prefs.setInt('checklist_last_photo_index', index);
      }

      if (!mounted) {
        return;
      }

      await _processarFoto(image, index);
      
    } catch (e, stack) {
      print('ERRO: $e');
      print(stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    _pendingPhotoIndex = null;
    await _saveState();
  }

  Future<void> _processarFoto(XFile image, int index) async {
    final item = _itens[index];

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      setState(() {
        item.setFotoBytes(bytes);
        item.setFoto(null);
        _itens[index] = item;
      });
      print('Foto salva (Web): ${bytes.length} bytes');
    } else {
      final imagePath = image.path;
      
      if (imagePath.isEmpty) {
        throw Exception('Path vazio');
      }

      final file = File(imagePath);
      final exists = await file.exists();
      
      if (!exists) {
        throw Exception('Arquivo não encontrado');
      }

      setState(() {
        item.setFoto(file);
        item.setFotoBytes(null);
        _itens[index] = item;
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto capturada!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _salvarChecklist() async {
    if (_selectedPlaca == null || _selectedMotorista == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecione a placa e o motorista."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_responsavelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Insira o nome do responsável."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Adicione a assinatura digital."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    for (final item in _itens) {
      if (item.getStatus() == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Responda o item '${item.getNome() ?? "sem nome"}'."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (item.getStatus() == false) {
        if (item.getComentario() == null || item.getComentario()!.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Adicione um comentário no item '${item.getNome() ?? "sem nome"}'."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (item.getFoto() == null && item.getFotoBytes() == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Adicione uma foto para o item '${item.getNome() ?? "sem nome"}'."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    // Mostra loading
    setState(() => _isLoading = true);

    try {
      final assinaturaBytes = await _signatureController.toPngBytes();
      final assinaturaBase64 = base64Encode(assinaturaBytes!);

      final api = APIService(widget.usuario.getServidor(), widget.usuario.getToken());
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

      if (mounted) {
        setState(() => _isLoading = false);
        
        if (sucesso) {
          // Limpa o estado salvo
          await _clearSavedState();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Checklist enviado com sucesso!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Aguarda um pouco para mostrar a mensagem
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Limpa todos os campos
          _limparFormulario();
          
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Erro ao enviar checklist."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Nova função para limpar o formulário
  void _limparFormulario() {
    setState(() {
      _selectedPlaca = null;
      _selectedMotorista = null;
      _motoristas = [];
      _itens = [];
      _responsavelController.clear();
      _signatureController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
          // Limpa o estado salvo ao sair da página
          await _clearSavedState();
          _limparFormulario();
        }
      },
      child: Scaffold(
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
                          child: Text(placa, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedPlaca = val;
                            _motoristas = [];
                            _selectedMotorista = null;
                          });
                          _saveState();
                          _loadMotoristas(widget.usuario);
                          _loadItens(
                            widget.usuario,
                            _veiculos.firstWhere((v) => v.getPlaca() == _selectedPlaca),
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
                      items: _motoristas.map(
                        (m) => DropdownMenuItem<String>(
                          value: m.getNome(),
                          child: Text(m.getNome() ?? 'unamed', style: const TextStyle(color: Colors.white)),
                        ),
                      ).toList(),
                      onChanged: (val) {
                        setState(() => _selectedMotorista = val);
                        _saveState();
                      },
                    ),
                    const Divider(color: Colors.white38, height: 40),
                    if (_selectedPlaca != null && _selectedMotorista != null)
                      ..._buildChecklist(),
                  ],
                ),
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
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.getStatus() == true ? Colors.green : Colors.grey[800],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          item.setStatus(true);
                          item.setComentario("");
                        });
                        _saveState(); // Salva após alterar
                      },
                      child: const Text("OK"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.getStatus() == false ? Colors.red : Colors.grey[800],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() => item.setStatus(false));
                        _saveState(); // Salva após alterar
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
                  controller: TextEditingController(text: item.getComentario() ?? ''),
                  onChanged: (value) {
                    item.setComentario(value);
                    _saveState(); // Salva após alterar
                  },
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera, color: Colors.white),
                    label: const Text("Abrir a câmera", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _selecionarImagem(index),
                  ),
                ),
                if (item.getFoto() != null || item.getFotoBytes() != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.memory(item.getFotoBytes()!, height: 150, width: double.infinity, fit: BoxFit.cover)
                        : Image.file(item.getFoto()!, height: 150, width: double.infinity, fit: BoxFit.cover),
                  ),
                ],
              ],
            ],
          ),
        );
      }),
      const Divider(color: Colors.white38, height: 40),
      const Text("Responsável pelo checklist:", style: TextStyle(color: Colors.white, fontSize: 16)),
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
        onChanged: (value) => _saveState(),
      ),
      const SizedBox(height: 20),
      const Text("Assinatura digital:", style: TextStyle(color: Colors.white, fontSize: 16)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[900],
        ),
        height: 150,
        child: Signature(controller: _signatureController, backgroundColor: Colors.grey[900]!),
      ),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => _signatureController.clear(),
          child: const Text("Limpar assinatura", style: TextStyle(color: Colors.redAccent)),
        ),
      ),
      const SizedBox(height: 30),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _salvarChecklist,
          child: const Text("Salvar Checklist", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    ];
  }
}