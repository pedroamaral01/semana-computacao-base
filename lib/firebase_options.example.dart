// ============================================================
// ARQUIVO DE EXEMPLO - firebase_options.dart
// ============================================================
// O Firebase no Android e iOS lê automaticamente dos arquivos
// nativos (google-services.json e GoogleService-Info.plist).
//
// Este arquivo só precisa conter a configuração para WEB.
//
// INSTRUÇÕES:
// 1. Copie este arquivo para: lib/firebase_options.dart
// 2. Substitua os valores "SEU_*" pelas credenciais Web
//    do Firebase Console → Configurações → Seus apps → Web
//
// Para Android/iOS, basta colocar os arquivos nativos:
//   - android/app/google-services.json
//   - ios/Runner/GoogleService-Info.plist
//
//  NÃO faça commit deste arquivo com credenciais reais.
// ============================================================

// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get web => _web;

  static const FirebaseOptions _web = FirebaseOptions(
    apiKey: 'SEU_API_KEY_WEB',
    authDomain: 'SEU_PROJETO.firebaseapp.com',
    projectId: 'SEU_PROJECT_ID',
    storageBucket: 'SEU_PROJETO.firebasestorage.app',
    messagingSenderId: 'SEU_MESSAGING_SENDER_ID',
    appId: 'SEU_APP_ID_WEB',
    measurementId: 'SEU_MEASUREMENT_ID',
  );
}
