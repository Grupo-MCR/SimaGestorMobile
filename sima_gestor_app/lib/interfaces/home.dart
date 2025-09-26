import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                        // Ação sair
                        Navigator.pop(context);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        enabled: false, // desabilita clique no nome
                        child: Column(
                          children: const [
                            Icon(Icons.account_circle,
                                color: Colors.white, size: 40),
                            SizedBox(height: 5),
                            Text(
                              "Carlos",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 1,
                        child: Text(
                          "Sair",
                          style: TextStyle(color: Colors.white),
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
                      icon: Icons.build,
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),
                    _buildMenuCard(
                      title: "Despesas",
                      icon: Icons.attach_money,
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),
                    _buildMenuCard(
                      title: "Checklists",
                      icon: Icons.assignment,
                      onTap: () {},
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
