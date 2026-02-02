import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/cadastro_screen.dart';
import '../screens/home_screen.dart';
import '../screens/minhas_inscricoes_screen.dart';
import '../screens/gerenciar_atividades_screen.dart';
import '../screens/cadastrar_atividade_screen.dart';
import '../screens/lista_presenca_screen.dart';
import '../screens/atividade_detail_screen.dart';

class Routes {
  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String home = '/home';
  static const String minhasInscricoes = '/minhas-inscricoes';
  static const String gerenciarAtividades = '/gerenciar-atividades';
  static const String cadastrarAtividade = '/cadastrar-atividade';
  static const String listaPresenca = '/lista-presenca';
  static const String atividadeDetail = '/atividade-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
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

      case atividadeDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final atividadeId = args?['atividadeId'] as String?;
        if (atividadeId == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Erro')),
              body: const Center(child: Text('ID da atividade não fornecido')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => AtividadeDetailScreen(atividadeId: atividadeId),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Erro')),
            body: Center(child: Text('Rota não encontrada: ${settings.name}')),
          ),
        );
    }
  }
}
