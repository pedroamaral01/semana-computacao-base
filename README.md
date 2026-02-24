# Aplicativo da Semana da Computação DECSI - UFOP

## Sobre o Projeto

Aplicativo móvel desenvolvido em **Flutter** para gerenciar e facilitar a participação na Semana da Computação do Departamento de Computação e Sistemas (DECSI) da Universidade Federal de Ouro Preto (UFOP).

O sistema oferece funcionalidades completas tanto para **participantes** quanto para **organizadores**, incluindo programação do evento, sistema de inscrições, check-in via QR Code, envio de perguntas e muito mais.

---

## Funcionalidades Principais

### Para Participantes

- **Autenticação** com email institucional (@ufop.edu.br)
- **Visualização da programação completa** com filtros por dia e tipo
- **Agenda personalizada** (favoritar atividades)
- **Sistema de inscrições** em minicursos com controle de vagas
- **QR Code pessoal** para check-in em atividades
- **Envio de perguntas anônimas** para palestrantes durante apresentações
- **Notificações automáticas** 10 minutos antes das atividades favoritadas

### Para Organizadores

- Todas as funcionalidades de participante
- **Cadastro e gerenciamento de atividades** (criar, editar, excluir)
- **Scanner de QR Code** para check-in de participantes
- **Lista de presença** em tempo real por atividade
- **Visualização de perguntas recebidas** por atividade
- **Controle de vagas** e estatísticas

---

## Tecnologias Utilizadas

### Framework e Linguagem

- **Flutter** 3.10.8
- **Dart** 3.0.0

### Backend e Serviços

- **Firebase Authentication** - Autenticação de usuários
- **Cloud Firestore** - Banco de dados NoSQL em tempo real
- **Firebase Cloud Messaging** - Notificações push

### Gerenciamento de Estado

- **Provider** 6.0.0

### Bibliotecas Principais

- **mobile_scanner** 3.5.0 - Scanner de QR Code
- **qr_flutter** 4.1.0 - Geração de QR Code
- **flutter_local_notifications** 16.0.0 - Notificações locais
- **shared_preferences** 2.2.0 - Armazenamento local
- **intl** 0.18.0 - Formatação de datas

### Arquitetura

- **Clean Architecture** - Separação de camadas (apresentação, domínio, dados)
- **Repository Pattern** - Abstração de fontes de dados

---

## Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versão 3.10.8 ou superior)
- [Dart SDK](https://dart.dev/get-dart) (versão 3.0.0 ou superior)
- [Android Studio](https://developer.android.com/studio) ou [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)

### Para executar em dispositivo físico ou emulador:

- **Android:** Android SDK (API 23+) - Android 6.0 ou superior
- **iOS:** Xcode 14+ e CocoaPods (apenas para macOS)

---

## Instalação e Configuração

### 1. Clone o repositório

```bash
git clone <url-do-repositorio>
cd semana-computacao-base
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. Configure o Firebase

#### 3.1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)

- **Nome do projeto:** `semana-computacao-decsi`

> **Importante:** O nome (Project ID) deve ser exatamente `semana-computacao-decsi` para que os arquivos de configuração já incluídos no projeto funcionem corretamente.

#### 3.2. Ative os seguintes serviços:

- **Authentication** (método: Email/Senha)
- **Cloud Firestore**
- **Cloud Messaging** (opcional)

#### 3.3. Configure os apps Android e iOS:

**Para Android:**

1. Baixe o arquivo `google-services.json` no Firebase Console
2. Coloque em: `android/app/google-services.json`
3. O Firebase lê as credenciais **automaticamente** deste arquivo em tempo de build (via plugin Gradle `com.google.gms.google-services`)

**Para iOS:**

1. Baixe o arquivo `GoogleService-Info.plist` no Firebase Console
2. Coloque em: `ios/Runner/GoogleService-Info.plist`
3. O Firebase lê as credenciais **automaticamente** deste arquivo

> **Não é necessário copiar chaves manualmente!** O Android e iOS inicializam direto dos arquivos nativos.

#### 3.4. Configure o arquivo `firebase_options.dart` (apenas Web)

O arquivo `firebase_options.dart` só é necessário para a versão **Web**. Android e iOS já leem dos arquivos nativos acima.

1. Copie o arquivo de exemplo:
   ```bash
   cp lib/firebase_options.example.dart lib/firebase_options.dart
   ```
2. Abra `lib/firebase_options.dart` e substitua os valores `SEU_*` pelas credenciais **Web** do Firebase Console:

| Placeholder              | Onde encontrar (Firebase Console → Apps → Web)      |
| ------------------------ | ---------------------------------------------------- |
| `SEU_API_KEY_WEB`        | `apiKey`                                             |
| `SEU_APP_ID_WEB`         | `appId`                                              |
| `SEU_PROJECT_ID`         | `projectId`                                          |
| `SEU_MESSAGING_SENDER_ID`| `messagingSenderId`                                  |
| `SEU_MEASUREMENT_ID`     | `measurementId` (Google Analytics)                   |

> **Segurança:** Nunca faça commit do `firebase_options.dart` com credenciais reais em repositórios públicos. Ele já está no `.gitignore`.

**Alternativa automática (recomendado):**

Se tiver o FlutterFire CLI instalado, ele gera o arquivo automaticamente:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

#### 3.5. Atualize as regras do Firestore

No **Firebase Console** → **Firestore Database** → **Rules**, cole as regras abaixo (também disponíveis no arquivo `firestore.rules` do projeto):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() {
      return request.auth != null;
    }

    // Usuários - Qualquer autenticado pode ler (necessário para validações)
    match /usuarios/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isAuthenticated() && request.auth.uid == userId;
      allow delete: if false;
    }

    // Atividades - Todos autenticados podem ler e escrever
    match /atividades/{atividadeId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }

    // Inscrições - Criação e leitura para autenticados, sem delete
    match /inscricoes/{inscricaoId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated();
      allow delete: if false;
    }

    // Perguntas
    match /perguntas/{perguntaId} {
      allow read, write: if isAuthenticated();
    }

    // Favoritos
    match /favoritos/{favoritoId} {
      allow read, write: if isAuthenticated();
    }
  }
}
```

#### 3.6. Crie as coleções no Firestore

No **Firebase Console** → **Firestore Database** → **Data**, crie as seguintes coleções (basta criar a primeira documento em cada uma ou deixar que o app crie automaticamente):

| Coleção       | Descrição                                       |
| ------------- | ----------------------------------------------- |
| `usuarios`    | Perfis dos usuários (nome, email, tipoUsuario)  |
| `atividades`  | Palestras, minicursos, workshops do evento      |
| `inscricoes`  | Inscrições dos participantes nas atividades     |
| `perguntas`   | Perguntas enviadas durante as apresentações     |
| `favoritos`   | Atividades favoritadas por cada usuário         |

### 4. Verifique a instalação

```bash
flutter doctor -v
```

Certifique-se de que não há erros críticos ().

---

## Como Executar

### Executar no emulador/dispositivo

```bash
flutter run
```

### Executar em modo debug

```bash
flutter run --debug
```

### Executar em modo release (Android)

```bash
flutter run --release
```

### Selecionar dispositivo específico

```bash
# Listar dispositivos disponíveis
flutter devices

# Executar em dispositivo específico
flutter run -d <device-id>
```

---

## Estrutura do Projeto

```
lib/
├── app/                        # Configuração do aplicativo
│   ├── app.dart               # Widget principal do app
│   └── routes.dart            # Definição de rotas
│
├── core/                       # Funcionalidades centrais
│   ├── constants/
│   │   └── app_colors.dart    # Cores do tema
│   ├── utils/
│   │   └── validators.dart    # Validadores de formulário
│   └── widgets/               # Widgets reutilizáveis
│
├── data/                       # Camada de dados
│   ├── models/                # Modelos de dados
│   │   ├── inscricao.dart
│   │   └── usuario.dart
│   ├── providers/             # Gerenciamento de estado (Provider)
│   │   ├── auth_provider.dart
│   │   ├── atividade_provider.dart
│   │   ├── agenda_provider.dart
│   │   └── pergunta_provider.dart
│   └── repositories/          # (Mock) Repositórios de dados
│
├── domain/                     # Camada de domínio
│   └── entities/              # Entidades de negócio
│       └── atividade.dart
│
├── screens/                    # Telas do aplicativo
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── cadastro_screen.dart
│   ├── home_screen.dart
│   ├── programacao_screen.dart
│   ├── atividade_detail_screen.dart
│   ├── minha_agenda_screen.dart
│   ├── minhas_inscricoes_screen.dart
│   ├── checkin_screen.dart
│   ├── perguntas_recebidas_screen.dart
│   ├── gerenciar_atividades_screen.dart
│   ├── cadastrar_atividade_screen.dart
│   └── lista_presenca_screen.dart
│
├── services/                   # Serviços
│   ├── firebase_auth_service.dart      # Autenticação Firebase
│   ├── firestore_service.dart          # CRUD Firestore
│   ├── notification_service.dart       # Notificações locais
│   └── storage_service.dart            # SharedPreferences
│
├── firebase_options.dart       # Configuração Firebase
└── main.dart                   # Ponto de entrada do app
```

---

## Usuários de Teste

Para testar o aplicativo, você pode criar usuários com emails institucionais ou usar credenciais de teste:

### Participante

- **Email:** `participante@ufop.edu.br`
- **Senha:** Qualquer senha (mínimo 6 caracteres)

### Organizador

- **Email:** `organizador@ufop.edu.br`
- **Senha:** Qualquer senha (mínimo 6 caracteres)

**Nota:** No primeiro acesso, será necessário criar o usuário através da tela de cadastro.

---

## Testes

### Executar todos os testes

```bash
flutter test
```

### Análise estática de código

```bash
flutter analyze
```

### Verificar formatação

```bash
flutter format --set-exit-if-changed .
```

---

## Build para Produção

### Android (APK)

```bash
flutter build apk --release
```

O APK será gerado em: `build/app/outputs/flutter-apk/app-release.apk`

### Android (App Bundle)

```bash
flutter build appbundle --release
```

O AAB será gerado em: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

## Documentação Acadêmica

Este projeto inclui documentação completa para fins acadêmicos:

- **EAP.md** - Estrutura Analítica do Projeto (PMBOK)
- **ESPECIFICACAO_REQUISITOS.md** - Especificação de Requisitos de Software (IEEE 830-1998)

---

## Segurança

- Autenticação obrigatória para acesso
- Validação de email institucional (@ufop.edu.br)
- Regras de segurança no Firestore
- Transações atômicas para controle de vagas
- Dados sensíveis não expostos no código

---

## Guia Rápido para Quem Clonou o Projeto

Checklist completo para rodar o projeto do zero:

```
[ ] 1. git clone <url> && cd semana-computacao-base
[ ] 2. flutter pub get
[ ] 3. Criar projeto no Firebase Console
[ ] 4. Ativar Authentication (Email/Senha) no Firebase
[ ] 5. Ativar Cloud Firestore no Firebase
[ ] 6. Baixar google-services.json → android/app/  (Android lê automaticamente)
[ ] 7. Baixar GoogleService-Info.plist → ios/Runner/ (iOS lê automaticamente)
[ ] 8. Copiar lib/firebase_options.example.dart → lib/firebase_options.dart
[ ] 9. Preencher apenas as credenciais Web em firebase_options.dart
[ ] 10. Colar as regras de firestore.rules no Firebase Console → Rules
[ ] 11. flutter doctor -v  (verificar se está tudo ok)
[ ] 12. flutter run
```

> **Dica:** Alternativamente, em vez dos passos 6-9, use `flutterfire configure` para gerar tudo automaticamente.

---

## Troubleshooting

### Erro: "Waiting for another flutter command to release the startup lock..."

```bash
# Windows
taskkill /F /IM dart.exe

# Linux/Mac
killall -9 dart
```

### Erro: Firebase não configurado

Certifique-se de que os arquivos `google-services.json` (Android) e `GoogleService-Info.plist` (iOS) estão nas pastas corretas.

### Erro: Gradle build failed

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Emulador iOS não inicia

```bash
# Reinstalar pods
cd ios
pod deintegrate
pod install
cd ..
```

---

## Licença

Este projeto foi desenvolvido para fins acadêmicos como parte do curso de Gerência de Projetos de Software do DECSI/UFOP.

---

## Desenvolvimento

**Instituição:** Universidade Federal de Ouro Preto (UFOP)  
**Departamento:** Departamento de Computação e Sistemas (DECSI)  
**Disciplina:** Gerência de Projetos de Software  
**Ano:** 2026

---
