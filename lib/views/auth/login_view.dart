import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:personal_trx_app/exceptions/api_exceptions.dart';
import 'package:personal_trx_app/providers/auth_provider.dart';
import 'package:personal_trx_app/services/auth/auth_service.dart';
import 'package:personal_trx_app/views/personal/personal_index_view.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  AuthProvider _authProvider = AuthProvider('');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      String token = await _authService.login(_emailController.text, _passwordController.text);
      await _authProvider.login(token);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PersonalIndexView()),
      );
    } on ApiExceptions catch (error) {
      debugPrint(error.toString());
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(error.toString());
      }
    } catch (error) {
      debugPrint(error.toString());
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(error.toString());
      }
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                'Erro',
                style: TextStyle(color: Colors.red),
              ),
              content: Text(
                msg,
                style: const TextStyle(fontSize: 18),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Fechar'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Container(
              color: Colors.grey[900],
              child: const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              child: Center(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 0,
                    color: const Color(0xff303030),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage("assets/images/logo.png"),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Personal RX',
                              style: TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
                              decoration: const InputDecoration(
                                icon: Icon(FontAwesomeIcons.envelope),
                                labelText: 'Email',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              controller: _emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Celular obrigatório';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              decoration: const InputDecoration(
                                icon: Icon(FontAwesomeIcons.lock),
                                labelText: 'Senha',
                              ),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              controller: _passwordController,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Senha obrigatória';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 45,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 16),
                                  primary: Colors.amber,
                                  onPrimary: Colors.black,
                                ),
                                onPressed: _submit,
                                child: const Text(
                                  'Entrar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Esqueceu a senha?'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
