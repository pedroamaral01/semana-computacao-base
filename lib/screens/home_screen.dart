import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../data/providers/auth_provider.dart';
import '../data/providers/agenda_provider.dart';
import 'programacao_screen.dart';
import 'minha_agenda_screen.dart';
import 'checkin_screen.dart';
import 'minhas_inscricoes_screen.dart';
import 'gerenciar_atividades_screen.dart';
import 'lista_presenca_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Configura o usuário no AgendaProvider após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final agendaProvider = Provider.of<AgendaProvider>(
        context,
        listen: false,
      );

      if (authProvider.currentUser != null) {
        agendaProvider.setUsuario(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOrganizador = authProvider.isOrganizador;

    final List<Widget> screens = [
      const ProgramacaoScreen(),
      const MinhaAgendaScreen(),
      const MinhasInscricoesScreen(),
      if (isOrganizador) const CheckinScreen(),
    ];

    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today),
        label: AppStrings.programacao,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.bookmark),
        label: AppStrings.minhaAgenda,
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.assignment),
        label: 'Inscrições',
      ),
      if (isOrganizador)
        const BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: AppStrings.checkin,
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [
          if (isOrganizador) ...[
            IconButton(
              icon: const Icon(Icons.event),
              tooltip: 'Gerenciar Atividades',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GerenciarAtividadesScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.people),
              tooltip: 'Lista de Presença',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListaPresencaScreen(),
                  ),
                );
              },
            ),
          ],
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.grey,
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }
}
