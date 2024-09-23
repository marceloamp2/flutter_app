import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:personal_trx_app/providers/auth_provider.dart';
import 'package:personal_trx_app/utils/app_routes.dart';
import 'package:personal_trx_app/views/auth/auth_guard.dart';
import 'package:personal_trx_app/views/personal/personal_index_view.dart';
import 'package:provider/provider.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider('')),
      ],
      child: MaterialApp(
        title: 'Personal TRX',
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.authGuard,
        routes: {
          AppRoutes.authGuard: (context) => const AuthGuard(),
          AppRoutes.home: (context) => const PersonalIndexView(),
        },
      ),
    );
  }
}
