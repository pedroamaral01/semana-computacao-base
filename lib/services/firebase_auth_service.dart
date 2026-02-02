import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/usuario.dart' as app_models;
import 'package:uuid/uuid.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Cadastrar novo usuário
  Future<app_models.Usuario?> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String tipo,
  }) async {
    try {
      // Criar usuário no Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final uid = userCredential.user!.uid;
      final qrCode = 'USER_${_uuid.v4()}';

      // Criar documento no Firestore
      final usuario = app_models.Usuario(
        id: uid,
        nome: nome,
        email: email,
        tipo: tipo,
        qrCode: qrCode,
      );

      await _firestore.collection('usuarios').doc(uid).set(usuario.toJson());

      return usuario;
    } catch (e) {
      print('Erro ao cadastrar usuário: $e');
      return null;
    }
  }

  // Login
  Future<app_models.Usuario?> login({
    required String email,
    required String senha,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final uid = userCredential.user!.uid;
      final doc = await _firestore.collection('usuarios').doc(uid).get();

      if (doc.exists) {
        return app_models.Usuario.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Erro ao fazer login: $e');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Obter dados do usuário
  Future<app_models.Usuario?> getUsuario(String uid) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        return app_models.Usuario.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Erro ao obter usuário: $e');
      return null;
    }
  }

  // Atualizar usuário
  Future<void> atualizarUsuario(app_models.Usuario usuario) async {
    await _firestore
        .collection('usuarios')
        .doc(usuario.id)
        .update(usuario.toJson());
  }

  // Obter usuário por QR Code
  Future<app_models.Usuario?> getUsuarioByQrCode(String qrCode) async {
    try {
      final querySnapshot = await _firestore
          .collection('usuarios')
          .where('qrCode', isEqualTo: qrCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return app_models.Usuario.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário por QR Code: $e');
      return null;
    }
  }
}
