import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/validators.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/custom_text_field.dart';
import '../data/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    // Validar email UFOP
    if (!Validators.isValidUfopEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.emailInvalido),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(email, senha);

    if (mounted) {
      if (success) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email não encontrado no sistema'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                const Icon(
                  Icons.computer,
                  size: 80,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.appName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                CustomTextField(
                  label: AppStrings.email,
                  hintText: 'seu.email@ufop.edu.br',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (!Validators.isNotEmpty(value)) {
                      return AppStrings.campoObrigatorio;
                    }
                    if (!Validators.isValidEmail(value!)) {
                      return AppStrings.emailInvalidoFormato;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: AppStrings.senha,
                  controller: _senhaController,
                  obscureText: true,
                  validator: (value) {
                    if (!Validators.isNotEmpty(value)) {
                      return AppStrings.campoObrigatorio;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: AppStrings.entrar,
                      onPressed: _handleLogin,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Apenas usuários com email do domínio ufop.edu.br',
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/cadastro');
                  },
                  child: const Text(
                    'Não tem uma conta? Cadastre-se',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
