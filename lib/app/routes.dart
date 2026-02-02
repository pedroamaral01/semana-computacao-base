import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/cadastro_screen.dart';
import '../screens/home_screen.dart';
import '../screens/atividade_detail_screen.dart';
import '../screens/minhas_inscricoes_screen.dart';
import '../screens/cadastrar_atividade_screen.dart';
import '../screens/gerenciar_atividades_screen.dart';
import '../screens/lista_presenca_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String home = '/home';
  static const String atividadeDetail = '/atividade-detail';
  static const String minhasInscricoes = '/minhas-inscricoes';
  static const String cadastrarAtividade = '/cadastrar-atividade';
  static const String gerenciarAtividades = '/gerenciar-atividades';
  static const String listaPresenca = '/lista-presenca';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      cadastro: (context) => const CadastroScreen(),
      home: (context) => const HomeScreen(),
      minhasInscricoes: (context) => const MinhasInscricoesScreen(),
      gerenciarAtividades: (context) => const GerenciarAtividadesScreen(),
      listaPresenca: (context) => const ListaPresencaScreen(),
    };
  }

  // Rota para AtividadeDetailScreen (com parâmetros)
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case atividadeDetail:
        final atividadeId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => AtividadeDetailScreen(atividadeId: atividadeId),
          settings: settings,
        );
      case cadastrarAtividade:
        final atividade = settings.arguments; // pode ser null para criar nova
        return MaterialPageRoute(
          builder: (context) => CadastrarAtividadeScreen(atividade: atividade),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
