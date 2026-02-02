# Semana da Computação DECSI - App Flutter

Aplicativo completo desenvolvido em Flutter para gerenciar e acompanhar a Semana da Computação do DECSI - UFOP.

## 📱 Funcionalidades

### Autenticação
- ✅ Login restrito a emails @ufop.edu.br
- ✅ Dois tipos de usuário: Participante e Organizador
- ✅ Persistência de sessão

### Para Participantes
- ✅ Visualização da programação completa
- ✅ Filtros por dia e tipo de atividade
- ✅ Favoritar atividades (Minha Agenda)
- ✅ Notificações 10 minutos antes das atividades
- ✅ Inscrição em minicursos
- ✅ Envio de perguntas em palestras ao vivo

### Para Organizadores
- ✅ Todas as funcionalidades de participante
- ✅ Scanner de QR Code para check-in
- ✅ Visualização de perguntas recebidas

## 🏗️ Arquitetura

O projeto segue **Clean Architecture** com **Provider** para gerenciamento de estado:

```
lib/
├── app/                    # Configuração do app
│   ├── app.dart           # Widget principal
│   └── routes.dart        # Definição de rotas
├── core/                  # Funcionalidades centrais
│   ├── constants/         # Cores e strings
│   ├── utils/            # Validadores
│   └── widgets/          # Widgets reutilizáveis
├── data/                 # Camada de dados
│   ├── models/           # Modelos de dados
│   ├── providers/        # Providers (estado)
│   └── repositories/     # Repositórios (mock)
├── screens/              # Telas do aplicativo
└── services/             # Serviços (storage, notificações)
```

## 🚀 Como executar

### Pré-requisitos
- Flutter SDK 3.10.8 ou superior
-  3.0Dart ou superior
- Android Studio / VS Code
- Dispositivo Android 6.0+ ou iOS 12+

### Instalação

1. Clone o repositório:
```bash
cd semana_computacao_app
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o aplicativo:
```bash
flutter run
```

## 📦 Dependências

- **provider**: ^6.0.0 - Gerenciamento de estado
- **shared_preferences**: ^2.2.0 - Armazenamento local
- **flutter_local_notifications**: ^16.0.0 - Notificações
- **mobile_scanner**: ^3.5.0 - Scanner de QR Code
- **intl**: ^0.18.0 - Formatação de datas
- **qr_flutter**: ^4.1.0 - Geração de QR Code
- **cupertino_icons**: ^1.0.6 - Ícones iOS

## 👥 Usuários de Teste

### Participante
- **Email**: participante@ufop.edu.br
- **Senha**: qualquer (não validada no mock)

### Organizador
- **Email**: organizador@ufop.edu.br
- **Senha**: qualquer (não validada no mock)

## 📅 Dados Mock

O aplicativo inclui:
- 10 atividades distribuídas em 3 dias (10-12 de março de 2026)
- Mix de palestras e minicursos
- Diferentes estados de vagas
- Atividade ao vivo para teste de perguntas

## 🎨 Design

### Paleta de Cores
- **Primary Blue**: #003366 (Azul UFOP)
- **Accent Gold**: #FFCC00 (Dourado)
- **Background**: #F5F5F5
- **Success**: #4CAF50
- **Error**: #E53935

### Componentes
- Material Design 3
- Bottom Navigation
- Cards com elevação
- Botões customizados
- TextFields padronizados

## 📱 Telas

1. **Splash Screen** - Tela inicial com logo
2. **Login** - Autenticação com validação @ufop.edu.br
3. **Home** - Menu principal com bottom navigation
4. **Programação** - Lista completa de atividades com filtros
5. **Detalhes da Atividade** - Informações completas + inscrição/perguntas
6. **Minha Agenda** - Atividades favoritadas
7. **Check-in** - Scanner QR (organizador)
8. **Perguntas Recebidas** - Visualização de perguntas (organizador)

## 🔔 Notificações

As notificações são agendadas automaticamente:
- 10 minutos antes de cada atividade favoritada
- Pode ser ativado/desativado na tela Minha Agenda
- Persiste entre sessões

## 🔒 Validação de Email

O sistema aceita **apenas emails @ufop.edu.br**:
```dart
bool isValidUfopEmail(String email) {
  return email.toLowerCase().endsWith('@ufop.edu.br');
}
```

## 🚧 Melhorias Futuras

- [ ] Integração com backend real
- [ ] Sistema de autenticação com senha
- [ ] Geração de QR Code para participantes
- [ ] Push notifications remotas
- [ ] Modo offline completo
- [ ] Compartilhamento de atividades
- [ ] Avaliação de atividades

## 📄 Licença

Este projeto foi desenvolvido para fins educacionais.

## 👨‍💻 Desenvolvimento

Desenvolvido seguindo as especificações do documento de requisitos da Semana da Computação DECSI - UFOP.
