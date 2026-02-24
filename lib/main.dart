import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Web: precisa de opções explícitas
    // Android/iOS/macOS: lê automaticamente dos arquivos nativos
    //   - android/app/google-services.json
    //   - ios/Runner/GoogleService-Info.plist
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.web,
      );
    } else {
      await Firebase.initializeApp();
    }
    print('Firebase inicializado com sucesso!');
  } catch (e, stackTrace) {
    print('Erro ao inicializar Firebase: $e');
    print('Stack trace: $stackTrace');
  }

  runApp(const App());
}
