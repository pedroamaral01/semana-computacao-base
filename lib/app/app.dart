import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/providers/auth_provider.dart';
import '../data/providers/atividade_provider.dart';
import '../data/providers/agenda_provider.dart';
import '../data/providers/pergunta_provider.dart';
import 'routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AtividadeProvider()),
        ChangeNotifierProvider(create: (_) => AgendaProvider()),
        ChangeNotifierProvider(create: (_) => PerguntaProvider()),
      ],
      child: MaterialApp(
        title: 'Semana da Computação',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        initialRoute: Routes.login,
        onGenerateRoute: Routes.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
