import 'package:flutter/material.dart';
import 'package:sima_gestor_app/model/usuario.dart';
import 'home_interface.dart';
import '../service/login_service.dart';



typedef RestorableRouteBuilder<T> = Route<T> Function(BuildContext context, dynamic arguments);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with RestorationMixin{

  final RestorableTextEditingController _emailController = RestorableTextEditingController();
  final RestorableTextEditingController _urlController = RestorableTextEditingController();
  final RestorableTextEditingController _senhaController = RestorableTextEditingController();

  @override
  String? get restorationId => 'loginPageRestoration';

  @override
    void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_emailController, 'email');
    registerForRestoration(_senhaController, 'senha');
    registerForRestoration(_urlController, 'url');
  }

  @pragma('vm:entry-point')
  static Route<Object?> _homeRouteBuilder(BuildContext context, dynamic arguments) {
    return MaterialPageRoute<Object?>(
      builder: (BuildContext context) => HomePage(usuario: arguments),
    );
  }

  RestorableRouteBuilder<Object?> hRoute = (BuildContext context, dynamic arguments) =>
        MaterialPageRoute(
          builder: (context) => HomePage(usuario: arguments),
        );

  bool _loading = false;

  Future<void> _handleLogin() async {
    setState(() => _loading = true);

    try {
      final logged = await LoginService.login(
        _emailController.value.text.trim(),
        _senhaController.value.text.trim(),
        _urlController.value.text.trim(),
      );

      // se deu certo -> navega
      Navigator.restorablePushReplacement(
        context, _homeRouteBuilder
      );
    } catch (e) {
      // se deu erro -> mostra snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "SimaGestor",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // Card de Login
              Card(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.white24),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email
                      TextField(
                        controller: _emailController.value,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),

                      // Prefixo - URL
                      TextField(
                        controller: _urlController.value,
                        decoration: const InputDecoration(
                          labelText: "Prefixo - URL",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),

                      // Senha
                      TextField(
                        controller: _senhaController.value,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Senha",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),

                      // Botão Entrar
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: _loading ? null : _handleLogin,
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Entrar",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Rodapé
              const Text.rich(
                TextSpan(
                  text: "From ",
                  style: TextStyle(color: Colors.white70),
                  children: [ 
                    TextSpan(
                      text: "simagestor.com.br",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
}
