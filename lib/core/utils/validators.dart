class Validators {
  static bool isValidUfopEmail(String email) {
    // Aceita qualquer email que termine com ufop.edu.br
    // Exemplos: @ufop.edu.br, @aluno.ufop.edu.br, @professor.ufop.edu.br
    return email.toLowerCase().endsWith('ufop.edu.br');
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
