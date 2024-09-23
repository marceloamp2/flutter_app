import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:personal_trx_app/exceptions/api_exceptions.dart';
import 'package:personal_trx_app/providers/auth_provider.dart';
import 'package:personal_trx_app/services/auth/auth_service.dart';
import 'package:personal_trx_app/views/auth/login_view.dart';
import 'package:provider/provider.dart';

import '../header.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  late AuthProvider _authProvider = AuthProvider('');
  Map<String, dynamic> userable = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _getUserable();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _getUserable() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      AuthService _authService = AuthService();
      userable = await _authService.userable(_authProvider.getToken);

      _nameController.text = userable['name'];

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _authProvider.logout();
      debugPrint(e.toString());
    }
  }

  Future<void> _submit() async {
    try {
      FocusScope.of(context).unfocus();

      if (!_formKey.currentState!.validate()) {
        return;
      }

      // chamada para trocar a senha

      _passwordController.text = '';
      _passwordConfirmationController.text = '';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: const Text(
            'Alterado com sucesso!',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          action: SnackBarAction(
            label: 'Fechar',
            textColor: Colors.black,
            onPressed: () {
              // Code to execute.
            },
          ),
        ),
      );
    } on ApiExceptions catch (error) {
      debugPrint(error.toString());
      _showErrorDialog(error.toString());
    } catch (error) {
      debugPrint(error.toString());
      _showErrorDialog(error.toString());
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
                  child: const Text(
                    'Fechar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Header(title: 'Meu perfil'),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: Colors.amber,
                                width: 1.3,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nome: ${userable['name']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Email: ${userable['user']['email']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(
                                FontAwesomeIcons.idCard,
                                size: 20,
                              ),
                              labelText: 'Nome',
                            ),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nome obrigatório';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(
                                FontAwesomeIcons.key,
                                size: 20,
                              ),
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
                          const SizedBox(height: 15),
                          TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(
                                FontAwesomeIcons.key,
                                size: 20,
                              ),
                              labelText: 'Confirmar senha',
                            ),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            controller: _passwordConfirmationController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirmação de senha obrigatória';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.amber,
                                onPrimary: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: _submit,
                              child: Text(
                                'Alterar'.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _authProvider.logout();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginView()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.amber,
                            onPrimary: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                          child: Text('Sair'.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 15,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
