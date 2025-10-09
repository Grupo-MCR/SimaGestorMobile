import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

class CheckListPage extends StatefulWidget {
  const CheckListPage({super.key});

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

  final List<Map<String, dynamic>> _itens = [
    {"nome": "Nível do óleo", "status": null, "imagem": null, "descricao": ""},
    {"nome": "Nível da água", "status": null, "imagem": null, "descricao": ""},
    {"nome": "Pneus e rodas", "status": null, "imagem": null, "descricao": ""},
    {"nome": "Combustível", "status": null, "imagem": null, "descricao": ""},
    {"nome": "Luzes", "status": null, "imagem": null, "descricao": ""},
    {
      "nome": "Limpador de para-brisa",
      "status": null,
      "imagem": null,
      "descricao": "",
    },
    {
      "nome": "Kit de troca de pneu",
      "status": null,
      "imagem": null,
      "descricao": "",
    },
    {"nome": "Freio", "status": null, "imagem": null, "descricao": ""},
  ];

  Future<void> _selecionarImagem(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        // Para Web: lê os bytes
        final bytes = await image.readAsBytes();
        setState(() {
          _itens[index]["imagem"] = bytes;
        });
      } else {
        // Para Mobile: usa o arquivo físico
        setState(() {
          _itens[index]["imagem"] = File(image.path);
        });
      }
    }
  }

  void _salvarChecklist() {
    // Verifica se todos os itens foram respondidos
    bool todosRespondidos = _itens.every((item) => item["status"] != null);

    if (!todosRespondidos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Responda todos os itens do checklist antes de finalizar.",
          ),
        ),
      );
      return;
    }

    if (_responsavelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, insira o nome do responsável."),
        ),
      );
      return;
    }

    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, adicione a assinatura digital."),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Checklist salvo com sucesso!")),
    );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      item["nome"],
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
                              backgroundColor: item["status"] == true
                                  ? Colors.green
                                  : Colors.grey[800],
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                item["status"] = true;
                                item["imagem"] = null;
                                item["descricao"] = "";
                              });
                            },
                            child: const Text("OK"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: item["status"] == false
                                  ? Colors.red
                                  : Colors.grey[800],
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                item["status"] = false;
                              });
                            },
                            child: const Text("Não OK"),
                          ),
                        ),
                      ],
                    ),
                    if (item["status"] == false) ...[
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
                          item["descricao"] = value;
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo, color: Colors.white),
                        label: const Text(
                          "Anexar foto da galeria",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _selecionarImagem(index),
                      ),
                      if (item["imagem"] != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? Image.memory(
                                  item["imagem"],
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  item["imagem"],
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
          ],
        ),
      ),
    );
  }
}
