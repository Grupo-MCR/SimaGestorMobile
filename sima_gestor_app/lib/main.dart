import 'package:flutter/material.dart';
import 'interface/login_interface.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      restorationScopeId: 'root',
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // chama a tela de login
    );
  }
}
