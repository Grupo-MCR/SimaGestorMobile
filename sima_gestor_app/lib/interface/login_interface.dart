import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'home_interface.dart';
import '../service/login_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  //final TextEditingController emailborder = TextEditingController(text: "true"); 
  Color _borderEmail = Colors.white24;
  Color _borderUrl = Colors.white24;
  Color _borderSenha = Colors.white24;

  bool _loading = false;

  Future<void> _handleLogin() async {
    setState(() => _loading = true);

    try {
      final logged = await LoginService.login(
        _emailController.text.trim(),
        _senhaController.text.trim(),
        _urlController.text.trim(),
      );

      // se deu certo -> navega
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(usuario: logged),
        ),
      );
    } on ClientException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("ClientException: ", "")),
          backgroundColor: Colors.red,
        ),
      );
      _borderEmail = Colors.white24;
      _borderSenha = Colors.white24;
      _borderUrl = Colors.red;
    } on Exception catch (e) {
      // se deu erro -> mostra snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
      _borderUrl = Colors.white24;
      _borderEmail = Colors.red;
      _borderSenha = Colors.red;
    } finally {
      setState(() => _loading = false);
    }
  }

  void rebuild() {
    setState(() => _loading = true);
    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    _urlController.addListener(rebuild);
  }

  @override
  void dispose() {
    super.dispose();
    _urlController.removeListener(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    final String prefixoUrl = _urlController.text.trim()==""?"":_urlController.text.trim() + ".";
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
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: _borderEmail),
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
                        controller: _urlController,
                        decoration: InputDecoration(
                          labelText: "Empresa / Prefixo URL",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: _borderUrl),
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
                        controller: _senhaController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Senha",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: _borderSenha),
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
              Text.rich(
                TextSpan(
                  text: "Entrando em ",
                  style: TextStyle(color: Colors.white70),
                  children: [
                    TextSpan(
                      text: prefixoUrl + "simagestor.com.br",
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