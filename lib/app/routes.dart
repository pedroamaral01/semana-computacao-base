import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/cadastro_screen.dart';
import '../screens/home_screen.dart';
import '../screens/minhas_inscricoes_screen.dart';
import '../screens/gerenciar_atividades_screen.dart';
import '../screens/cadastrar_atividade_screen.dart';
import '../screens/lista_presenca_screen.dart';

class Routes {
  static const String login = '/';
  static const String cadastro = '/cadastro';
  static const String home = '/home';
  static const String minhasInscricoes = '/minhas-inscricoes';
  static const String gerenciarAtividades = '/gerenciar-atividades';
  static const String cadastrarAtividade = '/cadastrar-atividade';
  static const String listaPresenca = '/lista-presenca';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case cadastro:
        return MaterialPageRoute(builder: (_) => const CadastroScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case minhasInscricoes:
        return MaterialPageRoute(
          builder: (_) => const MinhasInscricoesScreen(),
        );

      case gerenciarAtividades:
        return MaterialPageRoute(
          builder: (_) => const GerenciarAtividadesScreen(),
        );

      case cadastrarAtividade:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) =>
              CadastrarAtividadeScreen(atividade: args?['atividade']),
        );

      case listaPresenca:
        return MaterialPageRoute(builder: (_) => const ListaPresencaScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Rota não encontrada: ${settings.name}')),
          ),
        );
    }
  }
}
