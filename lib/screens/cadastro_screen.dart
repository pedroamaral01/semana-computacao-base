import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/validators.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/custom_text_field.dart';
import '../data/providers/auth_provider.dart';
import '../data/providers/agenda_provider.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();
  String _tipoSelecionado = 'Participante';

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }

  Future<void> _handleCadastro() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final senha = _senhaController.text;
    final confirmaSenha = _confirmaSenhaController.text;

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

    // Validar confirmação de senha
    if (senha != confirmaSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.cadastrar(
      nome: _nomeController.text.trim(),
      email: email,
      senha: senha,
      tipo: _tipoSelecionado,
    );

    if (mounted) {
      if (success) {
        // Configura o AgendaProvider com o usuário cadastrado
        final agendaProvider = Provider.of<AgendaProvider>(
          context,
          listen: false,
        );
        if (authProvider.currentUser != null) {
          await agendaProvider.setUsuario(authProvider.currentUser!.id);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao realizar cadastro. Tente novamente.'),
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
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add,
                  size: 80,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Criar Conta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  label: 'Nome Completo',
                  controller: _nomeController,
                  validator: (value) {
                    if (!Validators.isNotEmpty(value)) {
                      return AppStrings.campoObrigatorio;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
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
                DropdownButtonFormField<String>(
                  value: _tipoSelecionado,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Usuário',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Participante',
                      child: Text('Participante'),
                    ),
                    DropdownMenuItem(
                      value: 'Organizador',
                      child: Text('Organizador'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _tipoSelecionado = value!;
                    });
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
                    if (value!.length < 6) {
                      return 'A senha deve ter no mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Confirmar Senha',
                  controller: _confirmaSenhaController,
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
                      text: 'Cadastrar',
                      onPressed: _handleCadastro,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Já tenho uma conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
