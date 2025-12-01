import 'package:flutter/material.dart';
import '../model/usuario.dart';
import 'checklist_interface.dart';
import '../interface/despesa_interface.dart';
import '../interface/abastecimento_interface.dart';

class HomePage extends StatefulWidget {
  final Usuario usuario;

  const HomePage({super.key, required this.usuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // IMPORTANTE para AutomaticKeepAliveClientMixin
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "SimaGestor",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  /// MENU SUPERIOR DIREITO
                  PopupMenuButton<int>(
                    color: Colors.grey[800],
                    icon: const Icon(Icons.menu, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onSelected: (value) {
                      if (value == 1) {
                        _handleLogout();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        enabled: false,
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.account_circle,
                                color: Colors.white,
                                size: 40,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                widget.usuario.getNome() ?? "Usuário",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.usuario.getEmail() ?? "",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 1,
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Sair",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Lista de Cards
              Expanded(
                child: ListView(
                  children: [
                    _buildMenuCard(
                      title: "Abastecimentos",
                      icon: Icons.local_gas_station,
                      onTap: () => _navigateToAbastecimentos(),
                    ),
                    const SizedBox(height: 20),
                    _buildMenuCard(
                      title: "Despesas",
                      icon: Icons.attach_money,
                      onTap: () => _navigateToDespesas(),
                    ),
                    const SizedBox(height: 20),
                    _buildMenuCard(
                      title: "Checklists",
                      icon: Icons.assignment,
                      onTap: () => _navigateToChecklists(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAbastecimentos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroManualPage(usuario: widget.usuario),
      ),
    );
  }

  void _navigateToDespesas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InterfaceDespesas(
          servidor: widget.usuario.getServidor(),
          token: widget.usuario.getToken() ?? '',
        ),
      ),
    );
  }

  void _navigateToChecklists() {
    
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckListPage(usuario: widget.usuario),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao abrir Checklists: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Sair',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Deseja realmente sair?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o dialog
              Navigator.pop(context); // Volta para login
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.white24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Icon(icon, color: Colors.white70, size: 60),
            ],
          ),
        ),
      ),
    );
  }
}