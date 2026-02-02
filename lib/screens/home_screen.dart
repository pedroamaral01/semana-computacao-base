import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../data/providers/auth_provider.dart';
import 'programacao_screen.dart';
import 'minha_agenda_screen.dart';
import 'checkin_screen.dart';
import 'perguntas_recebidas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOrganizador = authProvider.isOrganizador;

    final List<Widget> screens = [
      const ProgramacaoScreen(),
      const MinhaAgendaScreen(),
      if (isOrganizador) const CheckinScreen(),
      if (isOrganizador) const PerguntasRecebidasScreen(),
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
      if (isOrganizador)
        const BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: AppStrings.checkin,
        ),
      if (isOrganizador)
        const BottomNavigationBarItem(
          icon: Icon(Icons.question_answer),
          label: AppStrings.perguntas,
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [
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
