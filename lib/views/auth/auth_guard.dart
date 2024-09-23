import 'package:flutter/material.dart';
import 'package:personal_trx_app/providers/auth_provider.dart';
import 'package:personal_trx_app/views/auth/login_view.dart';
import 'package:personal_trx_app/views/personal/personal_index_view.dart';
import 'package:provider/provider.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthProvider _authProvider = Provider.of(context);

    return FutureBuilder(
      future: _authProvider.autoLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            color: Colors.white,
            child: Center(
              child: Text('${snapshot.error}'),
            ),
          );
        } else {
          return _authProvider.isAuthenticated ? const PersonalIndexView() : const LoginView();
        }
      },
    );
  }
}
